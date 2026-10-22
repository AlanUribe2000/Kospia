BEGIN;

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    observation_id TEXT NOT NULL,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    old_species_id TEXT NULL,
    old_species_name TEXT NULL,
    new_species_id TEXT NULL,
    new_species_name TEXT NULL,
    read_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.notifications
    ADD CONSTRAINT notifications_type_check
    CHECK (type IN ('validated', 'rejected', 'species_changed'));

ALTER TABLE public.notifications
    ADD CONSTRAINT notifications_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public.users(id)
    ON DELETE CASCADE;

ALTER TABLE public.notifications
    ADD CONSTRAINT notifications_observation_id_fkey
    FOREIGN KEY (observation_id)
    REFERENCES public.observations(id)
    ON DELETE CASCADE;

CREATE INDEX idx_notifications_user_created
    ON public.notifications (user_id, created_at DESC);

CREATE INDEX idx_notifications_user_unread
    ON public.notifications (user_id)
    WHERE read_at IS NULL;

CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    token TEXT NOT NULL,
    platform TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.device_tokens
    ADD CONSTRAINT device_tokens_platform_check
    CHECK (platform IN ('android', 'ios', 'web'));

ALTER TABLE public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public.users(id)
    ON DELETE CASCADE;

ALTER TABLE public.device_tokens
    ADD CONSTRAINT device_tokens_token_key
    UNIQUE (token);

COMMIT;
