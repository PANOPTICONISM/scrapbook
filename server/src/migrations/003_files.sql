CREATE TABLE IF NOT EXISTS files (
    id          TEXT PRIMARY KEY NOT NULL,
    mime        TEXT NOT NULL,
    size        INTEGER NOT NULL,
    created_at  INTEGER NOT NULL
);
