BEGIN;

SET LOCAL lock_timeout = '5s';

DO $$
BEGIN
    IF to_regclass('public.questions') IS NULL OR
       to_regclass('public.question_options') IS NULL OR
       to_regclass('public.species_traits') IS NULL THEN
        RAISE EXCEPTION '009: falta el catálogo existente de preguntas, opciones o rasgos';
    END IF;
END
$$;

ALTER TABLE public.question_options
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS icon_attachment_id TEXT,
    ADD COLUMN IF NOT EXISTS icon_extension TEXT;

CREATE TABLE IF NOT EXISTS public.question_option_photos (
    id             TEXT PRIMARY KEY,
    option_id      TEXT NOT NULL
        REFERENCES public.question_options(id) ON DELETE CASCADE,
    order_index    INT NOT NULL DEFAULT 0,
    file_extension TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

LOCK TABLE public.question_option_photos IN ACCESS EXCLUSIVE MODE;

DO $$
DECLARE
    expected RECORD;
    actual RECORD;
    photos_oid OID := 'public.question_option_photos'::regclass;
    options_oid OID := 'public.question_options'::regclass;
    option_attnum SMALLINT;
    id_attnum SMALLINT;
BEGIN
    FOR expected IN
        SELECT * FROM (VALUES
            (options_oid, 'description', 'text'::regtype, false),
            (options_oid, 'icon_attachment_id', 'text'::regtype, false),
            (options_oid, 'icon_extension', 'text'::regtype, false),
            (photos_oid, 'id', 'text'::regtype, true),
            (photos_oid, 'option_id', 'text'::regtype, true),
            (photos_oid, 'order_index', 'integer'::regtype, true),
            (photos_oid, 'file_extension', 'text'::regtype, false),
            (photos_oid, 'created_at', 'timestamp with time zone'::regtype, true)
        ) AS columns(table_oid, column_name, column_type, not_null)
    LOOP
        SELECT atttypid, atttypmod, attnotnull INTO actual
        FROM pg_attribute
        WHERE attrelid = expected.table_oid AND attname = expected.column_name
          AND attnum > 0 AND NOT attisdropped;
        IF NOT FOUND OR actual.atttypid <> expected.column_type
           OR actual.atttypmod <> -1 OR actual.attnotnull <> expected.not_null THEN
            RAISE EXCEPTION '009: columna incompatible o ausente: %.%',
                expected.table_oid::regclass, expected.column_name;
        END IF;
    END LOOP;

    IF EXISTS (
        SELECT 1 FROM pg_attribute extra
        WHERE extra.attrelid = photos_oid AND extra.attnum > 0 AND NOT extra.attisdropped
          AND extra.attname NOT IN ('id', 'option_id', 'order_index', 'file_extension', 'created_at')
          AND extra.attnotnull AND NOT extra.atthasdef
          AND extra.attidentity = '' AND extra.attgenerated = ''
    ) THEN
        RAISE EXCEPTION '009: columna adicional obligatoria incompatible en question_option_photos';
    END IF;

    SELECT attnum INTO option_attnum FROM pg_attribute
    WHERE attrelid = photos_oid AND attname = 'option_id' AND NOT attisdropped;
    SELECT attnum INTO id_attnum FROM pg_attribute
    WHERE attrelid = photos_oid AND attname = 'id' AND NOT attisdropped;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = photos_oid AND contype = 'p'
          AND conkey = ARRAY[id_attnum] AND convalidated
    ) THEN
        RAISE EXCEPTION '009: clave primaria incompatible en question_option_photos';
    END IF;

    IF (SELECT count(*) FROM pg_constraint
        WHERE conrelid = photos_oid AND contype = 'f'
          AND option_attnum = ANY(conkey)) <> 1 OR NOT EXISTS (
        SELECT 1 FROM pg_constraint foreign_key
        JOIN pg_attribute referenced ON referenced.attrelid = options_oid
            AND referenced.attname = 'id' AND NOT referenced.attisdropped
        WHERE foreign_key.conrelid = photos_oid AND foreign_key.contype = 'f'
          AND foreign_key.conkey = ARRAY[option_attnum]
          AND foreign_key.confrelid = options_oid
          AND foreign_key.confkey = ARRAY[referenced.attnum]
          AND foreign_key.confdeltype = 'c' AND foreign_key.confupdtype = 'a'
          AND foreign_key.confmatchtype = 's' AND foreign_key.convalidated
          AND NOT foreign_key.condeferrable
    ) THEN
        RAISE EXCEPTION '009: clave foránea incompatible en question_option_photos.option_id';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_attrdef defaults
        JOIN pg_attribute column_info ON column_info.attrelid = defaults.adrelid
            AND column_info.attnum = defaults.adnum
        WHERE defaults.adrelid = photos_oid AND column_info.attname = 'order_index'
          AND pg_get_expr(defaults.adbin, defaults.adrelid) = '0'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_attrdef defaults
        JOIN pg_attribute column_info ON column_info.attrelid = defaults.adrelid
            AND column_info.attnum = defaults.adnum
        WHERE defaults.adrelid = photos_oid AND column_info.attname = 'created_at'
          AND pg_get_expr(defaults.adbin, defaults.adrelid) = 'now()'
    ) THEN
        RAISE EXCEPTION '009: valores por defecto incompatibles en question_option_photos';
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_question_option_photos_option_order
    ON public.question_option_photos (option_id, order_index);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_index index_info
        JOIN pg_class index_relation ON index_relation.oid = index_info.indexrelid
        JOIN pg_am access_method ON access_method.oid = index_relation.relam
        WHERE index_info.indexrelid = 'public.idx_question_option_photos_option_order'::regclass
          AND index_info.indrelid = 'public.question_option_photos'::regclass
          AND access_method.amname = 'btree'
          AND index_info.indisvalid AND index_info.indisready
          AND NOT index_info.indisunique AND NOT index_info.indisexclusion
          AND index_info.indnkeyatts = 2 AND index_info.indnatts = 2
          AND index_info.indpred IS NULL AND index_info.indexprs IS NULL
          AND index_info.indkey[0] = (SELECT attnum FROM pg_attribute
              WHERE attrelid = index_info.indrelid AND attname = 'option_id' AND NOT attisdropped)
          AND index_info.indkey[1] = (SELECT attnum FROM pg_attribute
              WHERE attrelid = index_info.indrelid AND attname = 'order_index' AND NOT attisdropped)
          AND index_info.indoption[0] = 0 AND index_info.indoption[1] = 0
          AND index_info.indcollation[0] = (SELECT attcollation FROM pg_attribute
              WHERE attrelid = index_info.indrelid AND attname = 'option_id' AND NOT attisdropped)
          AND index_info.indcollation[1] = (SELECT attcollation FROM pg_attribute
              WHERE attrelid = index_info.indrelid AND attname = 'order_index' AND NOT attisdropped)
          AND index_info.indclass[0] = (SELECT oid FROM pg_opclass
              WHERE opcmethod = index_relation.relam AND opcintype = 'text'::regtype AND opcdefault)
          AND index_info.indclass[1] = (SELECT oid FROM pg_opclass
              WHERE opcmethod = index_relation.relam AND opcintype = 'integer'::regtype AND opcdefault)
    ) THEN
        RAISE EXCEPTION '009: índice idx_question_option_photos_option_order incompatible';
    END IF;
END
$$;

COMMIT;