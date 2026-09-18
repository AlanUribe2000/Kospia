CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    google_sub TEXT UNIQUE,
    email TEXT,
    display_name TEXT,
    photo_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
