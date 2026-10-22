BEGIN;

ALTER TABLE public.observation_photos
    ADD COLUMN validation_status TEXT NOT NULL DEFAULT 'pending',
    ADD COLUMN validation_comment TEXT NULL,
    ADD COLUMN validated_species_id TEXT NULL,
    ADD COLUMN validated_at TIMESTAMPTZ NULL,
    ADD COLUMN validated_by UUID NULL;

ALTER TABLE public.observation_photos
    ADD CONSTRAINT observation_photos_validation_status_check
    CHECK (validation_status IN ('pending', 'validated', 'rejected'));

ALTER TABLE public.observation_photos
    ADD CONSTRAINT observation_photos_validated_species_id_fkey
    FOREIGN KEY (validated_species_id)
    REFERENCES public.species(id)
    ON DELETE RESTRICT;

ALTER TABLE public.observation_photos
    ADD CONSTRAINT observation_photos_validated_by_fkey
    FOREIGN KEY (validated_by)
    REFERENCES public.users(id)
    ON DELETE SET NULL;

CREATE INDEX idx_observation_photos_validation_status
    ON public.observation_photos (validation_status);

CREATE INDEX idx_observation_photos_validated_species_id
    ON public.observation_photos (validated_species_id);

COMMIT;
