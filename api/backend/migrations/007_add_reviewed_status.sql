BEGIN;

-- Amplía el estado agregado de observación para admitir 'reviewed'
-- (todas las fotos decididas). Se conservan 'validated'/'rejected' en el
-- CHECK para no romper filas históricas previas a este modelo.
ALTER TABLE public.observations
    DROP CONSTRAINT observations_validation_status_check;

ALTER TABLE public.observations
    ADD CONSTRAINT observations_validation_status_check
    CHECK (validation_status IN ('pending', 'validated', 'rejected', 'reviewed'));

-- (Opcional, documentado) Reclasifica a 'reviewed' las observaciones cuyas
-- fotos están todas decididas. Descomentar si se desea migrar históricos.
-- UPDATE public.observations o
-- SET validation_status = 'reviewed', updated_at = NOW()
-- WHERE o.validation_status IN ('validated', 'rejected')
--   AND EXISTS (SELECT 1 FROM public.observation_photos p WHERE p.observation_id = o.id)
--   AND NOT EXISTS (
--       SELECT 1 FROM public.observation_photos p
--       WHERE p.observation_id = o.id AND p.validation_status = 'pending'
--   );

COMMIT;
