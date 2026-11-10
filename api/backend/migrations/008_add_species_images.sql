-- 008: fotografías dinámicas del catálogo.
--  * public.species.updated_at (+ trigger) para que los clientes detecten cambios.
--  * public.species_images con los metadatos de las fotos oficiales.
-- Ejecutar UNA sola vez, con ON_ERROR_STOP, tras un pg_dump verificado.
-- No toca observaciones, fotografías de observaciones ni archivos en disco.
-- No define GRANT: la escritura queda restringida por el backend (rol admin).

BEGIN;

SET LOCAL lock_timeout = '5s';

-- Aborta (y revierte todo) si faltan prerrequisitos o si ya se aplicó.
DO $$
BEGIN
    IF to_regclass('public.species') IS NULL THEN
        RAISE EXCEPTION '008: falta public.species';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'id'
          AND data_type = 'uuid'
    ) THEN
        RAISE EXCEPTION '008: public.users.id no existe o no es uuid';
    END IF;

    IF to_regclass('public.species_images') IS NOT NULL THEN
        RAISE EXCEPTION '008: public.species_images ya existe (migración ya aplicada)';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'species'
          AND column_name = 'updated_at'
    ) THEN
        RAISE EXCEPTION '008: public.species.updated_at ya existe (migración ya aplicada)';
    END IF;
END
$$;

-- 1) species.updated_at: se agrega nullable, se inicializa con created_at y
--    luego se vuelve obligatoria. Solo se escribe la columna nueva.
ALTER TABLE public.species
    ADD COLUMN updated_at TIMESTAMPTZ;

UPDATE public.species
SET updated_at = COALESCE(created_at, NOW());

ALTER TABLE public.species
    ALTER COLUMN updated_at SET DEFAULT NOW(),
    ALTER COLUMN updated_at SET NOT NULL;

-- 2) Función y triggers de updated_at (se crean DESPUÉS del backfill).
CREATE FUNCTION public.kospia_set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_species_set_updated_at
    BEFORE UPDATE ON public.species
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION public.kospia_set_updated_at();

-- 3) species_images.
CREATE TABLE public.species_images (
    id            TEXT PRIMARY KEY,
    species_id    TEXT NOT NULL,
    file_name     TEXT NOT NULL,
    content_hash  TEXT NOT NULL,
    mime_type     TEXT NOT NULL,
    width         INTEGER,
    height        INTEGER,
    size_bytes    BIGINT NOT NULL,
    sort_order    INTEGER NOT NULL DEFAULT 0,
    is_primary    BOOLEAN NOT NULL DEFAULT FALSE,
    status        TEXT NOT NULL DEFAULT 'active',
    source_path   TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by    UUID,

    CONSTRAINT species_images_species_id_fkey
        FOREIGN KEY (species_id)
        REFERENCES public.species(id)
        ON DELETE RESTRICT,

    CONSTRAINT species_images_created_by_fkey
        FOREIGN KEY (created_by)
        REFERENCES public.users(id)
        ON DELETE SET NULL,

    CONSTRAINT species_images_file_name_check
        CHECK (length(btrim(file_name)) > 0),

    CONSTRAINT species_images_content_hash_check
        CHECK (content_hash ~ '^[0-9a-f]{64}$'),

    CONSTRAINT species_images_mime_type_check
        CHECK (mime_type IN ('image/jpeg', 'image/png', 'image/webp')),

    CONSTRAINT species_images_width_check
        CHECK (width IS NULL OR width BETWEEN 1 AND 20000),

    CONSTRAINT species_images_height_check
        CHECK (height IS NULL OR height BETWEEN 1 AND 20000),

    CONSTRAINT species_images_size_bytes_check
        CHECK (size_bytes BETWEEN 1 AND 20971520),

    CONSTRAINT species_images_sort_order_check
        CHECK (sort_order >= 0),

    CONSTRAINT species_images_status_check
        CHECK (status IN ('active', 'hidden')),

    CONSTRAINT species_images_primary_active_check
        CHECK (NOT is_primary OR status = 'active'),

    CONSTRAINT species_images_species_hash_key
        UNIQUE (species_id, content_hash)
);

CREATE INDEX idx_species_images_species_order
    ON public.species_images (species_id, sort_order);

-- Una sola foto principal activa por especie.
CREATE UNIQUE INDEX ux_species_images_one_primary
    ON public.species_images (species_id)
    WHERE is_primary AND status = 'active';

CREATE TRIGGER trg_species_images_set_updated_at
    BEFORE UPDATE ON public.species_images
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION public.kospia_set_updated_at();

COMMENT ON TABLE public.species_images IS
    'Fotografías oficiales del catálogo. Los archivos viven en el servidor; content_hash versiona la caché de los clientes.';
COMMENT ON COLUMN public.species_images.source_path IS
    'Ruta original del asset de Flutter (trazabilidad de la migración inicial).';

COMMIT;
