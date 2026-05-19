-- Tombstones record entities that have been hard-deleted, so other clients
-- syncing later can also remove them locally. Each tombstone is uniquely
-- identified by (entity_type, entity_id).
CREATE TABLE IF NOT EXISTS tombstones (
    entity_type TEXT NOT NULL,    -- 'page' | 'block' | 'database_property' | 'database_row' | 'database_property_value'
    entity_id   TEXT NOT NULL,
    deleted_at  INTEGER NOT NULL, -- Unix millis
    PRIMARY KEY (entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_tombstones_deleted_at ON tombstones(deleted_at);
