BEGIN;

-- Fichas de ayuda (FEAT-001, resuelto como Opción B en integración):
-- agrega al catálogo EXISTENTE (preguntas q-001..q-015 y sus opciones, que son
-- el set canónico del cuestionario y a las que apuntan las 1252 filas de
-- species_traits) las columnas y la tabla necesarias para colgar fichas de
-- ayuda: texto descriptivo + icono/logo por opción + galería de fotos.
--
-- IMPORTANTE (Opción B): NO se siembran preguntas ni opciones nuevas. El admin,
-- desde la web, agrega ayuda (descripción/icono/galería) a CUALQUIERA de las
-- preguntas/opciones del catálogo existente. Una opción sin ayuda cargada
-- simplemente no muestra contenido extra en la app (fallback actual).
--
-- Reutiliza los MISMOS nombres de columna que ya consume la app vía
-- PowerSync/Drift (powersync_schema.dart, tables.dart). Idempotente.

-- (a) Tablas base del catálogo: solo se garantiza su existencia (CREATE ...
-- IF NOT EXISTS), con los nombres de columna que usa la app. En entornos que
-- ya tienen el catálogo (q-001..q-015) estos CREATE son no-ops.
CREATE TABLE IF NOT EXISTS public.questions (
    id            TEXT PRIMARY KEY,
    question_text TEXT,
    field_name    TEXT,
    required_part TEXT DEFAULT 'general',
    order_index   INT,
    is_active     BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.question_options (
    id          TEXT PRIMARY KEY,
    question_id TEXT,
    option_text TEXT,
    value_key   TEXT DEFAULT '',
    order_index INT DEFAULT 0
);

-- (b) Columnas nuevas para la ficha de ayuda: descripción textual + icono/logo
-- de la opción (hoy lo dibuja Flutter; pasa a poder venir de la web). Guardamos
-- la extensión del icono para poder resolver el archivo al servirlo.
ALTER TABLE public.question_options
    ADD COLUMN IF NOT EXISTS description TEXT NULL;

ALTER TABLE public.question_options
    ADD COLUMN IF NOT EXISTS icon_attachment_id TEXT NULL;

ALTER TABLE public.question_options
    ADD COLUMN IF NOT EXISTS icon_extension TEXT NULL;

-- (c) Galería de fotos por opción. Referencia question_options(id) genérico:
-- sirve para CUALQUIER opción del catálogo (ids legacy opt-fb-* / opt-lf-* /
-- etc.), no solo para un subconjunto. file_extension permite resolver el
-- archivo físico guardado en uploads/opciones/<id>.<ext> al servirlo/borrarlo.
CREATE TABLE IF NOT EXISTS public.question_option_photos (
    id             TEXT PRIMARY KEY,
    option_id      TEXT NOT NULL
        REFERENCES public.question_options(id) ON DELETE CASCADE,
    order_index    INT NOT NULL DEFAULT 0,
    file_extension TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_question_option_photos_option_order
    ON public.question_option_photos (option_id, order_index);

-- (d) LIMPIEZA Opción B: una versión previa de esta migración sembró 8
-- preguntas "estables" (q-forma-*/q-color-*) + sus opciones opt-<field_name>-N,
-- que DUPLICABAN el catálogo canónico (q-001..q-015) y ensuciaban el
-- cuestionario de la app (preguntas repetidas). Se eliminan de forma
-- idempotente. Solo borra las opciones con el patrón de seed
-- 'opt-<field_name>-<n>' NO referenciadas por species_traits (las legacy usan
-- otro patrón: opt-fb-*, opt-lf-*, etc.), así que este DELETE no toca el
-- catálogo real. El ON DELETE CASCADE limpia cualquier foto asociada.
DELETE FROM public.question_options qo
WHERE qo.question_id IN (
        'q-forma-biologica', 'q-forma-hoja', 'q-borde-hoja', 'q-textura-hoja',
        'q-color-flor', 'q-agrupacion-flor', 'q-forma-fruto', 'q-color-fruto'
      )
  AND NOT EXISTS (
        SELECT 1 FROM public.species_traits st WHERE st.option_id = qo.id
      );

DELETE FROM public.questions
WHERE id IN (
    'q-forma-biologica', 'q-forma-hoja', 'q-borde-hoja', 'q-textura-hoja',
    'q-color-flor', 'q-agrupacion-flor', 'q-forma-fruto', 'q-color-fruto'
)
AND NOT EXISTS (
    SELECT 1 FROM public.question_options qo
    WHERE qo.question_id = public.questions.id
);

COMMIT;
