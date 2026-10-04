BEGIN;

ALTER TABLE public.observations
    ADD COLUMN validated_species_id TEXT NULL;

ALTER TABLE public.observations
    ADD CONSTRAINT observations_validated_species_id_fkey
    FOREIGN KEY (validated_species_id)
    REFERENCES public.species(id)
    ON DELETE RESTRICT;

CREATE INDEX idx_observations_validated_species_id
    ON public.observations (validated_species_id);

COMMIT;
