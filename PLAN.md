# Personal Knowledge Base — Implementation Plan

## Overview

Self-hosted, single-user, offline-first personal knowledge base. The server is a Rust/Axum single binary backed by SQLite, packaged in Docker. The client is a Flutter app targeting macOS, iOS, and Android. Sync is timestamp-based delta sync over REST with WebSocket push notifications. Auth is a single static API token.

---

## 1. Repository Layout

```
scrapbook/
├── server/
│   ├── Cargo.toml
│   ├── Cargo.lock
│   ├── src/
│   │   ├── main.rs
│   │   ├── config.rs
│   │   ├── db.rs
│   │   ├── auth.rs
│   │   ├── error.rs
│   │   ├── models/
│   │   │   ├── mod.rs
│   │   │   ├── page.rs
│   │   │   ├── block.rs
│   │   │   ├── database.rs
│   │   │   ├── database_row.rs
│   │   │   └── database_property.rs
│   │   ├── routes/
│   │   │   ├── mod.rs
│   │   │   ├── pages.rs
│   │   │   ├── blocks.rs
│   │   │   ├── databases.rs
│   │   │   ├── sync.rs
│   │   │   └── ws.rs
│   │   └── migrations/
│   │       └── 001_initial.sql
│   └── tests/
│       └── integration_test.rs
├── app/
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   ├── analysis_options.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── constants.dart
│   │   │   ├── router.dart
│   │   │   └── theme.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── auth_provider.dart
│   │   │   │   └── token_storage.dart
│   │   │   ├── pages/
│   │   │   │   ├── data/
│   │   │   │   │   ├── page_repository.dart
│   │   │   │   │   └── page_local_datasource.dart
│   │   │   │   ├── domain/
│   │   │   │   │   └── page_model.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── page_list_screen.dart
│   │   │   │       ├── page_editor_screen.dart
│   │   │   │       └── page_tree_sidebar.dart
│   │   │   ├── editor/
│   │   │   │   ├── markdown_editor.dart
│   │   │   │   └── editor_toolbar.dart
│   │   │   ├── databases/
│   │   │   │   ├── data/
│   │   │   │   │   ├── database_repository.dart
│   │   │   │   │   └── database_local_datasource.dart
│   │   │   │   ├── domain/
│   │   │   │   │   ├── database_model.dart
│   │   │   │   │   ├── database_row_model.dart
│   │   │   │   │   └── property_value.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── gallery_view.dart
│   │   │   │       └── table_view.dart
│   │   │   └── sync/
│   │   │       ├── sync_service.dart
│   │   │       ├── sync_provider.dart
│   │   │       └── ws_client.dart
│   │   ├── db/
│   │   │   ├── app_database.dart
│   │   │   └── tables/
│   │   │       ├── pages_table.dart
│   │   │       ├── blocks_table.dart
│   │   │       ├── databases_table.dart
│   │   │       ├── database_rows_table.dart
│   │   │       └── database_properties_table.dart
│   │   └── shared/
│   │       ├── widgets/
│   │       │   ├── sidebar.dart
│   │       │   └── empty_state.dart
│   │       └── utils/
│   │           └── datetime_utils.dart
│   ├── test/
│   ├── macos/
│   ├── ios/
│   └── android/
└── docker/
    ├── Dockerfile
    └── docker-compose.yml
```

---

## 2. Server Design

### 2.1 SQLite Schema (`server/src/migrations/001_initial.sql`)

```sql
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
```

### 2.2 Cargo.toml Dependencies

```toml
[package]
name = "scrapbook-server"
version = "0.1.0"
edition = "2021"

[dependencies]
axum            = { version = "0.7", features = ["ws", "macros"] }
tokio           = { version = "1",   features = ["full"] }
tower           = "0.4"
tower-http      = { version = "0.5", features = ["cors", "trace"] }
sqlx            = { version = "0.7", features = ["sqlite", "runtime-tokio", "macros", "migrate", "chrono", "uuid"] }
serde           = { version = "1",   features = ["derive"] }
serde_json      = "1"
uuid            = { version = "1",   features = ["v4"] }
chrono          = { version = "0.4", features = ["serde"] }
anyhow          = "1"
thiserror       = "1"
tracing         = "1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
futures         = "0.3"

[profile.release]
opt-level     = "z"
lto           = true
codegen-units = 1
strip         = true
```

### 2.3 REST API Routes

All routes require `Authorization: Bearer <token>`. All timestamps are Unix milliseconds (i64). All IDs are UUID v4 strings.

#### Pages
```
GET    /api/pages
GET    /api/pages/:id          (returns page + blocks)
POST   /api/pages
PATCH  /api/pages/:id
DELETE /api/pages/:id          (soft delete)
```

#### Blocks
```
GET    /api/pages/:page_id/blocks
POST   /api/blocks
PATCH  /api/blocks/:id
DELETE /api/blocks/:id
```

#### Databases
```
GET    /api/databases/:id/properties
POST   /api/databases/:id/properties
PATCH  /api/databases/:id/properties/:prop_id
DELETE /api/databases/:id/properties/:prop_id

GET    /api/databases/:id/rows
POST   /api/databases/:id/rows
PATCH  /api/databases/:id/rows/:row_id
DELETE /api/databases/:id/rows/:row_id

GET    /api/rows/:row_id/values
POST   /api/rows/:row_id/values
PATCH  /api/rows/:row_id/values/:value_id
```

#### Sync
```
GET  /api/sync?since=<unix_millis>
POST /api/sync
GET  /api/ws                   (WebSocket upgrade)
```

**GET /api/sync response:**
```json
{
  "server_time": 1716000010000,
  "pages": [],
  "blocks": [],
  "database_properties": [],
  "database_rows": [],
  "database_property_values": []
}
```

**POST /api/sync request:**
```json
{
  "pages": [],
  "blocks": [],
  "database_properties": [],
  "database_rows": [],
  "database_property_values": []
}
```

**POST /api/sync response:**
```json
{
  "server_time": 1716000012000,
  "accepted": { "pages": ["uuid1"], "blocks": [] },
  "rejected": { "pages": [], "blocks": [] }
}
```

### 2.4 WebSocket Protocol

Endpoint: `GET /api/ws?token=<token>`

Server → client (JSON):
```json
{ "type": "ping" }
{ "type": "change", "entity": "page",  "id": "uuid", "updated_at": 1716000005000 }
{ "type": "change", "entity": "block", "id": "uuid", "updated_at": 1716000005000 }
```

Client → server:
```json
{ "type": "pong" }
```

Server pings every 30s. Disconnects if no pong within 10s. Client reconnects with exponential backoff (1s → 2s → 4s → 8s → cap 60s).

---

## 3. Flutter App Design

### 3.1 pubspec.yaml Dependencies

```yaml
dependencies:
  flutter_riverpod:    ^2.5.1
  riverpod_annotation: ^2.3.5
  drift:               ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider:       ^2.1.3
  path:                ^1.9.0
  dio:                 ^5.4.3+1
  web_socket_channel:  ^2.4.5
  flutter_markdown:    ^0.7.1
  go_router:           ^14.2.0
  flutter_secure_storage: ^9.0.0
  uuid:                ^4.4.0
  freezed_annotation:  ^2.4.1
  json_annotation:     ^4.9.0
  intl:                ^0.19.0
  collection:          ^1.18.0
  connectivity_plus:   ^6.0.3

dev_dependencies:
  build_runner:        ^2.4.11
  drift_dev:           ^2.18.0
  riverpod_generator:  ^2.4.2
  freezed:             ^2.5.2
  json_serializable:   ^6.8.0
  mockito:             ^5.4.4
  flutter_lints:       ^4.0.0
```

### 3.2 Sync Service (last-write-wins)

- Client stores `lastSyncTime` in SharedPreferences (Unix millis from server clock)
- Every sync cycle: **push dirty records first**, then **pull since lastSyncTime**
- Pull: for each incoming server record, if `server.updated_at >= local.updated_at` → apply and clear `isDirty`
- Push: server compares `updated_at`; returns accepted list (clear `isDirty`) and rejected list (apply server version)
- Sync triggers: app foreground, WS change notification, 60s timer, 2s debounce after local writes

### 3.3 Navigation

```
/           → redirect to /pages
/setup      → token + server URL setup (first launch)
/pages      → shell: sidebar + empty right pane
/pages/:id  → shell: sidebar + markdown editor
/pages/:id/db           → shell: sidebar + database view
/pages/:id/db/:rowId    → shell: sidebar + row editor
```

Shell layout: 280px fixed sidebar + flex content pane on macOS/tablet. Drawer on mobile.

### 3.4 Local-only DB columns (not on server)

- `is_dirty`: set `true` on every local write; cleared when server accepts push
- `is_new`: set `true` on offline creation

---

## 4. Phased Build Order

### Phase 1 — Server Foundation
1. Cargo project scaffold + all dependencies
2. Config (env vars: `SCRAPBOOK_TOKEN`, `DATABASE_URL`, `HOST`, `PORT`)
3. SQLite migration setup (`sqlx::migrate!()`)
4. Auth middleware (constant-time token comparison)
5. Pages CRUD (5 routes)
6. Blocks CRUD (4 routes) — auto-create blank block on page creation
7. Docker: multi-stage Dockerfile + docker-compose.yml

**Milestone**: `docker compose up` → all page/block CRUD routes work via curl.

### Phase 2 — Flutter Foundation (local only)
1. Flutter project scaffold (`--platforms macos,ios,android`)
2. All Drift table definitions + `AppDatabase` + code generation
3. Freezed domain models
4. `PageRepository` (local reads/writes, sets `isDirty`)
5. Riverpod providers
6. go_router setup + `SetupScreen`
7. Shell layout (sidebar + content pane)
8. Page tree sidebar (tree from `parent_id`, create/navigate pages)
9. Markdown editor (TextField edit + flutter_markdown preview, debounced save)

**Milestone**: App runs on macOS. Pages persist locally. No server needed.

### Phase 3 — Sync Layer
1. Server: `GET /api/sync` + `POST /api/sync` endpoints
2. Server: WebSocket endpoint + broadcast on writes
3. Flutter: `DioClient` with auth interceptor + retry
4. Flutter: `WsClient` with reconnect backoff
5. Flutter: `SyncService` (push/pull/LWW logic)
6. Flutter: `SyncProvider` + sync triggers
7. Flutter: Setup screen with connection test
8. Flutter: Sync status indicator in sidebar

**Milestone**: Edit on macOS → appears on iOS within seconds. Offline edits sync on reconnect.

### Phase 4 — Database Feature
1. Server: database property + row + value CRUD routes
2. Server: include database entities in sync endpoints
3. Flutter: database domain models + `DatabaseRepository`
4. Flutter: new page creation flow (Page vs Database choice)
5. Flutter: table view with `PropertyCell` variants per type
6. Flutter: gallery view (`GridView` with property chips)
7. Flutter: view toggle (table/gallery), persisted per database
8. Flutter: property management (add/rename/delete via long-press)

**Milestone**: Full database feature working and syncing.

---

## 5. Key Technical Decisions

### Conflict resolution
Last-write-wins per record on `updated_at`. Granularity is per-block — two different blocks edited on two devices offline both survive. Only editing the *same* block on two devices simultaneously risks a loss (the older edit is overwritten). Acceptable for single-user.

### Sync clock
`lastSyncTime` is always set to `server_time` from the pull response — never the client clock. This prevents clock-skew bugs where a fast-clocked client misses records written by a slow-clocked server.

### Fractional indexing
`position REAL` for ordering pages and blocks. Insert between 1.0 and 2.0 → 1.5. If gap < 0.001, rebalance the list. Avoids renumbering on every reorder.

### Auth
Single static token in `SCRAPBOOK_TOKEN` env var. Stored in `flutter_secure_storage` on device. No sessions, no OAuth. Designed to run behind the user's own network (Tailscale/WireGuard recommended for remote access).

### Markdown editor (Phase 2)
Start simple: multiline `TextField` for editing + `flutter_markdown` for preview, toggled by toolbar button. Migration path to `appflowy_editor` in a later phase — store its JSON doc format in the `content` column with `type = 'appflowy'`.
