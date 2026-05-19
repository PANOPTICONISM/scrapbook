PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pages (
    id          TEXT PRIMARY KEY NOT NULL,
    parent_id   TEXT REFERENCES pages(id) ON DELETE SET NULL,
    title       TEXT NOT NULL DEFAULT '',
    icon        TEXT,
    is_database INTEGER NOT NULL DEFAULT 0,
    position    REAL NOT NULL DEFAULT 0.0,
    created_at  INTEGER NOT NULL,
    updated_at  INTEGER NOT NULL,
    deleted_at  INTEGER
);

CREATE TABLE IF NOT EXISTS blocks (
    id          TEXT PRIMARY KEY NOT NULL,
    page_id     TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
    type        TEXT NOT NULL DEFAULT 'markdown',
    content     TEXT NOT NULL DEFAULT '',
    position    REAL NOT NULL DEFAULT 0.0,
    created_at  INTEGER NOT NULL,
    updated_at  INTEGER NOT NULL,
    deleted_at  INTEGER
);

CREATE TABLE IF NOT EXISTS database_properties (
    id            TEXT PRIMARY KEY NOT NULL,
    database_id   TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
    name          TEXT NOT NULL,
    type          TEXT NOT NULL,
    options       TEXT,
    position      REAL NOT NULL DEFAULT 0.0,
    created_at    INTEGER NOT NULL,
    updated_at    INTEGER NOT NULL,
    deleted_at    INTEGER,
    UNIQUE(database_id, name)
);

CREATE TABLE IF NOT EXISTS database_rows (
    id            TEXT PRIMARY KEY NOT NULL,
    database_id   TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
    page_id       TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
    position      REAL NOT NULL DEFAULT 0.0,
    created_at    INTEGER NOT NULL,
    updated_at    INTEGER NOT NULL,
    deleted_at    INTEGER
);

CREATE TABLE IF NOT EXISTS database_property_values (
    id            TEXT PRIMARY KEY NOT NULL,
    row_id        TEXT NOT NULL REFERENCES database_rows(id) ON DELETE CASCADE,
    property_id   TEXT NOT NULL REFERENCES database_properties(id) ON DELETE CASCADE,
    value_text    TEXT,
    value_number  REAL,
    value_date    INTEGER,
    value_bool    INTEGER,
    value_select  TEXT,
    created_at    INTEGER NOT NULL,
    updated_at    INTEGER NOT NULL,
    UNIQUE(row_id, property_id)
);

CREATE INDEX IF NOT EXISTS idx_blocks_page_id      ON blocks(page_id);
CREATE INDEX IF NOT EXISTS idx_blocks_updated_at   ON blocks(updated_at);
CREATE INDEX IF NOT EXISTS idx_pages_parent_id     ON pages(parent_id);
CREATE INDEX IF NOT EXISTS idx_pages_updated_at    ON pages(updated_at);
CREATE INDEX IF NOT EXISTS idx_db_rows_db_id       ON database_rows(database_id);
CREATE INDEX IF NOT EXISTS idx_db_rows_updated_at  ON database_rows(updated_at);
CREATE INDEX IF NOT EXISTS idx_db_props_updated_at ON database_properties(updated_at);
CREATE INDEX IF NOT EXISTS idx_db_pvals_row_id     ON database_property_values(row_id);
