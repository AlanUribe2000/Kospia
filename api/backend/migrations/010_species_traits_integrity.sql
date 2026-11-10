BEGIN;

SET LOCAL lock_timeout = '5s';

LOCK TABLE public.species, public.questions, public.question_options,
    public.species_traits IN ACCESS EXCLUSIVE MODE;

DO $$
DECLARE
    conflicting_constraint TEXT;
BEGIN
    IF EXISTS (
        SELECT 1 FROM public.species_traits
        WHERE species_id IS NULL OR question_id IS NULL OR option_id IS NULL
    ) THEN
        RAISE EXCEPTION '010: species_traits contiene referencias nulas';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.species_traits trait
        LEFT JOIN public.species species ON species.id = trait.species_id
        LEFT JOIN public.questions question ON question.id = trait.question_id
        LEFT JOIN public.question_options option_row
            ON option_row.id = trait.option_id
           AND option_row.question_id = trait.question_id
        WHERE species.id IS NULL OR question.id IS NULL OR option_row.id IS NULL
    ) THEN
        RAISE EXCEPTION '010: species_traits contiene referencias inexistentes o una opcion de otra pregunta';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.species_traits
        GROUP BY species_id, question_id, option_id HAVING count(*) > 1
    ) THEN
        RAISE EXCEPTION '010: species_traits contiene rasgos duplicados';
    END IF;

    SELECT constraint_info.conname INTO conflicting_constraint
    FROM pg_constraint constraint_info
    WHERE constraint_info.conrelid = 'public.species_traits'::regclass
      AND constraint_info.contype = 'f'
      AND constraint_info.conkey && ARRAY[
          (SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'species_id' AND NOT attisdropped),
          (SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'question_id' AND NOT attisdropped),
          (SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'option_id' AND NOT attisdropped)
      ]::smallint[]
      AND NOT (
          constraint_info.convalidated AND NOT constraint_info.condeferrable
          AND constraint_info.confdeltype IN ('a', 'r')
          AND constraint_info.confupdtype IN ('a', 'r')
          AND constraint_info.confmatchtype = 's'
          AND (
              (constraint_info.conkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'species_id' AND NOT attisdropped)]
               AND constraint_info.confrelid = 'public.species'::regclass
               AND constraint_info.confkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.confrelid AND attname = 'id' AND NOT attisdropped)])
           OR (constraint_info.conkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'question_id' AND NOT attisdropped)]
               AND constraint_info.confrelid = 'public.questions'::regclass
               AND constraint_info.confkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.confrelid AND attname = 'id' AND NOT attisdropped)])
           OR (constraint_info.conkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'option_id' AND NOT attisdropped)]
               AND constraint_info.confrelid = 'public.question_options'::regclass
               AND constraint_info.confkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.confrelid AND attname = 'id' AND NOT attisdropped)])
           OR (constraint_info.conkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'option_id' AND NOT attisdropped), (SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.conrelid AND attname = 'question_id' AND NOT attisdropped)]
               AND constraint_info.confrelid = 'public.question_options'::regclass
               AND constraint_info.confkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.confrelid AND attname = 'id' AND NOT attisdropped), (SELECT attnum FROM pg_attribute WHERE attrelid = constraint_info.confrelid AND attname = 'question_id' AND NOT attisdropped)])
          )
      )
    LIMIT 1;

    IF conflicting_constraint IS NOT NULL THEN
        RAISE EXCEPTION '010: clave foranea incompatible en species_traits: %', conflicting_constraint;
    END IF;
END
$$;

ALTER TABLE public.species_traits
    ALTER COLUMN species_id SET NOT NULL,
    ALTER COLUMN question_id SET NOT NULL,
    ALTER COLUMN option_id SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_010_question_options_id_question
    ON public.question_options (id, question_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_010_species_traits_species_question_option
    ON public.species_traits (species_id, question_id, option_id);

DO $$
DECLARE
    expected RECORD;
BEGIN
    FOR expected IN SELECT * FROM (VALUES
        ('public.uq_010_question_options_id_question', 'public.question_options', ARRAY['id', 'question_id']),
        ('public.uq_010_species_traits_species_question_option', 'public.species_traits', ARRAY['species_id', 'question_id', 'option_id'])
    ) AS expected_indexes(index_name, table_name, column_names)
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_index index_info
            JOIN pg_class index_relation ON index_relation.oid = index_info.indexrelid
            JOIN pg_am access_method ON access_method.oid = index_relation.relam
            WHERE index_info.indexrelid = to_regclass(expected.index_name)
              AND index_info.indrelid = to_regclass(expected.table_name)
              AND index_info.indisunique AND index_info.indisvalid AND index_info.indisready
              AND index_info.indimmediate AND NOT index_info.indisexclusion
              AND index_info.indpred IS NULL AND index_info.indexprs IS NULL
              AND access_method.amname = 'btree'
              AND index_info.indnkeyatts = cardinality(expected.column_names)
              AND index_info.indnatts = cardinality(expected.column_names)
              AND NOT EXISTS (
                  SELECT 1 FROM generate_series(0, index_info.indnkeyatts - 1) AS positions(position)
                  JOIN pg_attribute attribute ON attribute.attrelid = index_info.indrelid
                      AND attribute.attnum = index_info.indkey[positions.position]
                  WHERE index_info.indoption[positions.position] <> 0
                     OR index_info.indcollation[positions.position] <> attribute.attcollation
                     OR index_info.indclass[positions.position] <> (
                         SELECT oid FROM pg_opclass
                         WHERE opcmethod = index_relation.relam
                           AND opcintype = attribute.atttypid AND opcdefault
                     )
              )
              AND ARRAY(SELECT attribute.attname::text
                  FROM unnest(index_info.indkey) WITH ORDINALITY AS keys(attnum, position)
                  JOIN pg_attribute attribute ON attribute.attrelid = index_info.indrelid
                      AND attribute.attnum = keys.attnum
                  ORDER BY keys.position) = expected.column_names
        ) THEN
            RAISE EXCEPTION '010: indice incompatible: %', expected.index_name;
        END IF;
    END LOOP;
END
$$;

DO $$
DECLARE
    trait_table OID := 'public.species_traits'::regclass;
    species_column SMALLINT;
    question_column SMALLINT;
    option_column SMALLINT;
BEGIN
    SELECT attnum INTO species_column FROM pg_attribute WHERE attrelid = trait_table AND attname = 'species_id' AND NOT attisdropped;
    SELECT attnum INTO question_column FROM pg_attribute WHERE attrelid = trait_table AND attname = 'question_id' AND NOT attisdropped;
    SELECT attnum INTO option_column FROM pg_attribute WHERE attrelid = trait_table AND attname = 'option_id' AND NOT attisdropped;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = trait_table AND contype = 'f' AND conkey = ARRAY[species_column] AND confrelid = 'public.species'::regclass) THEN
        ALTER TABLE public.species_traits ADD CONSTRAINT fk_010_traits_species
            FOREIGN KEY (species_id) REFERENCES public.species(id) ON DELETE NO ACTION;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = trait_table AND contype = 'f' AND conkey = ARRAY[question_column] AND confrelid = 'public.questions'::regclass) THEN
        ALTER TABLE public.species_traits ADD CONSTRAINT fk_010_traits_question
            FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE NO ACTION;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = trait_table AND contype = 'f' AND conkey = ARRAY[option_column, question_column] AND confrelid = 'public.question_options'::regclass) THEN
        ALTER TABLE public.species_traits ADD CONSTRAINT fk_010_traits_option_question
            FOREIGN KEY (option_id, question_id) REFERENCES public.question_options(id, question_id) ON DELETE NO ACTION;
    END IF;
END
$$;

COMMIT;