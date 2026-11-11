-- Verificación POSTERIOR a la migración 008 (solo lectura). No depende de la publicación powersync.
-- Uso: Get-Content api\backend\scripts\verify_008_post.sql -Raw |
--        docker exec -i -e PGOPTIONS='-c default_transaction_read_only=on' <contenedor> psql -U postgres -d <base> -X -P pager=off

\echo '[POST-1] Estructura (todas deben dar ok = t)'
SELECT 'species_images existe' AS chequeo, to_regclass('public.species_images') IS NOT NULL AS ok
UNION ALL
SELECT 'columnas de species_images', (
    SELECT array_agg(column_name::text ORDER BY column_name) FROM information_schema.columns
    WHERE table_schema='public' AND table_name='species_images')
    = ARRAY['content_hash','created_at','created_by','file_name','height','id','is_primary','mime_type',
            'size_bytes','sort_order','source_path','species_id','status','updated_at','width']
UNION ALL
SELECT '13 restricciones esperadas', (
    SELECT array_agg(conname::text ORDER BY conname) FROM pg_constraint
    WHERE conrelid = to_regclass('public.species_images') AND contype <> 'n')
    = ARRAY['species_images_content_hash_check','species_images_created_by_fkey','species_images_file_name_check',
            'species_images_height_check','species_images_mime_type_check','species_images_pkey',
            'species_images_primary_active_check','species_images_size_bytes_check','species_images_sort_order_check',
            'species_images_species_hash_key','species_images_species_id_fkey','species_images_status_check',
            'species_images_width_check']
UNION ALL
SELECT 'índices esperados', (
    SELECT array_agg(indexname::text ORDER BY indexname) FROM pg_indexes
    WHERE schemaname='public' AND tablename='species_images')
    = ARRAY['idx_species_images_species_order','species_images_pkey','species_images_species_hash_key',
            'ux_species_images_one_primary']
UNION ALL
SELECT 'índice de foto principal es parcial y único', EXISTS (
    SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='ux_species_images_one_primary'
      AND indexdef LIKE 'CREATE UNIQUE INDEX%' AND indexdef LIKE '%WHERE%')
UNION ALL
SELECT 'FK species_id ON DELETE RESTRICT hacia species(id)', EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname='species_images_species_id_fkey'
      AND pg_get_constraintdef(oid) LIKE '%REFERENCES species(id) ON DELETE RESTRICT%')
UNION ALL
SELECT 'FK created_by hacia users(id) ON DELETE SET NULL', EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname='species_images_created_by_fkey'
      AND pg_get_constraintdef(oid) LIKE '%REFERENCES users(id) ON DELETE SET NULL%')
UNION ALL
SELECT 'created_by es uuid', EXISTS (
    SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='species_images'
      AND column_name='created_by' AND data_type='uuid')
UNION ALL
SELECT 'species_images vacía', (SELECT count(*) FROM public.species_images) = 0;

\echo '[POST-2] Triggers y función (ok = t)'
SELECT 'trigger en species' AS chequeo, EXISTS (
    SELECT 1 FROM pg_trigger WHERE NOT tgisinternal AND tgrelid='public.species'::regclass
      AND tgname='trg_species_set_updated_at') AS ok
UNION ALL
SELECT 'trigger en species_images', EXISTS (
    SELECT 1 FROM pg_trigger WHERE NOT tgisinternal AND tgrelid='public.species_images'::regclass
      AND tgname='trg_species_images_set_updated_at')
UNION ALL
SELECT 'función kospia_set_updated_at', EXISTS (
    SELECT 1 FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname='kospia_set_updated_at');

\echo '[POST-3] species.updated_at (ok = t)'
SELECT 'columna timestamptz NOT NULL con default now()' AS chequeo, EXISTS (
    SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='species'
      AND column_name='updated_at' AND data_type='timestamp with time zone'
      AND is_nullable='NO' AND column_default LIKE 'now()%') AS ok
UNION ALL
SELECT 'ninguna fila con updated_at nulo', (SELECT count(*) FROM public.species WHERE updated_at IS NULL) = 0
UNION ALL
SELECT 'updated_at = created_at en todas las filas', (
    SELECT count(*) FROM public.species WHERE created_at IS NOT NULL AND updated_at <> created_at) = 0;

\echo '[POST-4] Cantidades conservadas'
SELECT (SELECT count(*) FROM public.species) = 79 AS species_79,
       (SELECT count(*) FROM public.species_traits) = 1252 AS traits_1252,
       (SELECT count(*) FROM public.species WHERE is_active) = 79 AS activas_79,
       (SELECT count(*) FROM public.questions) AS questions,
       (SELECT count(*) FROM public.question_options) AS question_options,
       (SELECT count(*) FROM public.observations) AS observations,
       (SELECT count(*) FROM public.observation_photos) AS observation_photos;

\echo '[POST-5] Huellas de datos (deben ser idénticas a verify_008_pre.sql)'
SELECT 'species (sin updated_at)' AS objeto,
       md5(string_agg((to_jsonb(s) - 'updated_at')::text, '|' ORDER BY s.id)) AS huella
FROM public.species s
UNION ALL
SELECT 'species_traits', md5(string_agg(to_jsonb(t)::text, '|' ORDER BY t.id)) FROM public.species_traits t
UNION ALL
SELECT 'questions', md5(string_agg(to_jsonb(q)::text, '|' ORDER BY q.id)) FROM public.questions q
UNION ALL
SELECT 'question_options', md5(string_agg(to_jsonb(o)::text, '|' ORDER BY o.id)) FROM public.question_options o
UNION ALL
SELECT 'observations', md5(string_agg(to_jsonb(ob)::text, '|' ORDER BY ob.id)) FROM public.observations ob
UNION ALL
SELECT 'observation_photos', md5(string_agg(to_jsonb(p)::text, '|' ORDER BY p.id)) FROM public.observation_photos p
UNION ALL
SELECT 'users', md5(string_agg(to_jsonb(u)::text, '|' ORDER BY u.id)) FROM public.users u;
