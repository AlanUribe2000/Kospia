-- Verificación PREVIA a la migración 008 (solo lectura). No depende de la publicación powersync.
-- Uso: Get-Content api\backend\scripts\verify_008_pre.sql -Raw |
--        docker exec -i -e PGOPTIONS='-c default_transaction_read_only=on' <contenedor> psql -U postgres -d <base> -X -P pager=off

\echo '[PRE-1] Condiciones para ejecutar la migración (todas deben dar ok = t)'
SELECT 'public.species existe' AS condicion, to_regclass('public.species') IS NOT NULL AS ok
UNION ALL
SELECT 'public.users existe', to_regclass('public.users') IS NOT NULL
UNION ALL
SELECT 'users.id es uuid', EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users' AND column_name='id' AND data_type='uuid')
UNION ALL
SELECT 'species.id es text', EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='species' AND column_name='id' AND data_type='text')
UNION ALL
SELECT 'species_images NO existe', to_regclass('public.species_images') IS NULL
UNION ALL
SELECT 'species.updated_at NO existe', NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='species' AND column_name='updated_at')
UNION ALL
SELECT 'función kospia_set_updated_at NO existe', NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname='kospia_set_updated_at')
UNION ALL
SELECT 'sin triggers trg_species* previos', NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE NOT tgisinternal AND tgname LIKE 'trg_species%');

\echo '[PRE-2] Cantidades'
SELECT (SELECT count(*) FROM public.species) AS species,
       (SELECT count(*) FROM public.species WHERE is_active) AS activas,
       (SELECT count(*) FROM public.species_traits) AS species_traits,
       (SELECT count(*) FROM public.questions) AS questions,
       (SELECT count(*) FROM public.question_options) AS question_options,
       (SELECT count(*) FROM public.observations) AS observations,
       (SELECT count(*) FROM public.observation_photos) AS observation_photos;

\echo '[PRE-3] Huellas de datos (deben coincidir con las de verify_008_post.sql)'
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
