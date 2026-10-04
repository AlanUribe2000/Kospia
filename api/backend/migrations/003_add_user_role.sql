BEGIN;

ALTER TABLE public.users
    ADD COLUMN role TEXT NOT NULL DEFAULT 'user';

ALTER TABLE public.users
    ADD CONSTRAINT users_role_check
    CHECK (role IN ('user', 'professional', 'admin'));

COMMIT;
