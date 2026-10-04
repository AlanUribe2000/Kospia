BEGIN;

ALTER TABLE public.observations
    ADD COLUMN validation_status TEXT NOT NULL DEFAULT 'pending',
    ADD COLUMN validated_at TIMESTAMPTZ NULL,
    ADD COLUMN validated_by UUID NULL,
    ADD COLUMN rejection_reason TEXT NULL;

ALTER TABLE public.observations
    ADD CONSTRAINT observations_validation_status_check
    CHECK (validation_status IN ('pending', 'validated', 'rejected'));

ALTER TABLE public.observations
    ADD CONSTRAINT observations_validated_by_fkey
    FOREIGN KEY (validated_by)
    REFERENCES public.users(id)
    ON DELETE SET NULL;

COMMIT;
