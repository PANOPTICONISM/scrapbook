use axum::{extract::State, extract::Query, Json};
use serde::Deserialize;
use std::sync::Arc;

use crate::{
    auth::AuthToken,
    error::Result,
    models::{
        block::Block,
        database::{DatabaseProperty, DatabasePropertyValue, DatabaseRow},
        page::Page,
        sync::*,
    },
    AppState,
};
use crate::models::sync::Tombstone;

use super::pages::now_millis;

#[derive(Deserialize)]
pub struct SinceQuery {
    pub since: Option<i64>,
}

pub async fn pull(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Query(q): Query<SinceQuery>,
) -> Result<Json<SyncPullResponse>> {
    let since = q.since.unwrap_or(0);

    let pages = sqlx::query_as::<_, Page>(
        "SELECT * FROM pages WHERE updated_at > ?",
    )
    .bind(since)
    .fetch_all(&state.db)
    .await?;

    let blocks = sqlx::query_as::<_, Block>(
        "SELECT * FROM blocks WHERE updated_at > ?",
    )
    .bind(since)
    .fetch_all(&state.db)
    .await?;

    let database_properties = sqlx::query_as::<_, DatabaseProperty>(
        "SELECT * FROM database_properties WHERE updated_at > ?",
    )
    .bind(since)
    .fetch_all(&state.db)
    .await?;

    let database_rows = sqlx::query_as::<_, DatabaseRow>(
        "SELECT * FROM database_rows WHERE updated_at > ?",
    )
    .bind(since)
    .fetch_all(&state.db)
    .await?;

    let database_property_values = sqlx::query_as::<_, DatabasePropertyValue>(
        "SELECT * FROM database_property_values WHERE updated_at > ?",
    )
    .bind(since)
    .fetch_all(&state.db)
    .await?;

    let tombstones = sqlx::query_as::<_, Tombstone>(
        "SELECT entity_type, entity_id, deleted_at FROM tombstones WHERE deleted_at > ?",
    )
    .bind(since)
    .fetch_all(&state.db)
    .await?;

    Ok(Json(SyncPullResponse {
        server_time: now_millis(),
        pages,
        blocks,
        database_properties,
        database_rows,
        database_property_values,
        tombstones,
    }))
}

pub async fn push(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Json(req): Json<SyncPushRequest>,
) -> Result<Json<SyncPushResponse>> {
    let mut accepted = AcceptedIds::default();
    let mut rejected = RejectedRecords::default();

    for page in req.pages {
        let existing = sqlx::query_as::<_, Page>("SELECT * FROM pages WHERE id = ?")
            .bind(&page.id)
            .fetch_optional(&state.db)
            .await?;

        match existing {
            None => {
                sqlx::query(
                    "INSERT INTO pages (id, parent_id, title, icon, is_database, position, created_at, updated_at, deleted_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                )
                .bind(&page.id)
                .bind(&page.parent_id)
                .bind(&page.title)
                .bind(&page.icon)
                .bind(page.is_database)
                .bind(page.position)
                .bind(page.created_at)
                .bind(page.updated_at)
                .bind(page.deleted_at)
                .execute(&state.db)
                .await?;
                accepted.pages.push(page.id.clone());
            }
            Some(existing) if page.updated_at >= existing.updated_at => {
                sqlx::query(
                    "UPDATE pages SET parent_id=?, title=?, icon=?, is_database=?, position=?, updated_at=?, deleted_at=?
                     WHERE id=?",
                )
                .bind(&page.parent_id)
                .bind(&page.title)
                .bind(&page.icon)
                .bind(page.is_database)
                .bind(page.position)
                .bind(page.updated_at)
                .bind(page.deleted_at)
                .bind(&page.id)
                .execute(&state.db)
                .await?;
                accepted.pages.push(page.id.clone());
            }
            Some(existing) => {
                rejected.pages.push(RejectedItem {
                    id: page.id.clone(),
                    reason: "server_newer".to_string(),
                    server_record: existing,
                });
            }
        }
    }

    for block in req.blocks {
        let existing = sqlx::query_as::<_, Block>("SELECT * FROM blocks WHERE id = ?")
            .bind(&block.id)
            .fetch_optional(&state.db)
            .await?;

        match existing {
            None => {
                sqlx::query(
                    "INSERT INTO blocks (id, page_id, type, content, position, created_at, updated_at, deleted_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                )
                .bind(&block.id)
                .bind(&block.page_id)
                .bind(&block.block_type)
                .bind(&block.content)
                .bind(block.position)
                .bind(block.created_at)
                .bind(block.updated_at)
                .bind(block.deleted_at)
                .execute(&state.db)
                .await?;
                accepted.blocks.push(block.id.clone());
            }
            Some(existing) if block.updated_at >= existing.updated_at => {
                sqlx::query(
                    "UPDATE blocks SET page_id=?, type=?, content=?, position=?, updated_at=?, deleted_at=?
                     WHERE id=?",
                )
                .bind(&block.page_id)
                .bind(&block.block_type)
                .bind(&block.content)
                .bind(block.position)
                .bind(block.updated_at)
                .bind(block.deleted_at)
                .bind(&block.id)
                .execute(&state.db)
                .await?;
                accepted.blocks.push(block.id.clone());
            }
            Some(existing) => {
                rejected.blocks.push(RejectedItem {
                    id: block.id.clone(),
                    reason: "server_newer".to_string(),
                    server_record: existing,
                });
            }
        }
    }

    // Upsert database entities (no rejection logic needed — last write wins)
    for prop in req.database_properties {
        sqlx::query(
            "INSERT INTO database_properties (id, database_id, name, type, options, position, created_at, updated_at, deleted_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET
               name=excluded.name, options=excluded.options, position=excluded.position,
               updated_at=excluded.updated_at, deleted_at=excluded.deleted_at
             WHERE excluded.updated_at >= updated_at",
        )
        .bind(&prop.id).bind(&prop.database_id).bind(&prop.name).bind(&prop.prop_type)
        .bind(&prop.options).bind(prop.position).bind(prop.created_at).bind(prop.updated_at).bind(prop.deleted_at)
        .execute(&state.db).await?;
        accepted.database_properties.push(prop.id);
    }

    for row in req.database_rows {
        sqlx::query(
            "INSERT INTO database_rows (id, database_id, page_id, position, created_at, updated_at, deleted_at)
             VALUES (?, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET
               position=excluded.position, updated_at=excluded.updated_at, deleted_at=excluded.deleted_at
             WHERE excluded.updated_at >= updated_at",
        )
        .bind(&row.id).bind(&row.database_id).bind(&row.page_id)
        .bind(row.position).bind(row.created_at).bind(row.updated_at).bind(row.deleted_at)
        .execute(&state.db).await?;
        accepted.database_rows.push(row.id);
    }

    for val in req.database_property_values {
        sqlx::query(
            "INSERT INTO database_property_values
               (id, row_id, property_id, value_text, value_number, value_date, value_bool, value_select, created_at, updated_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(row_id, property_id) DO UPDATE SET
               value_text=excluded.value_text, value_number=excluded.value_number,
               value_date=excluded.value_date, value_bool=excluded.value_bool,
               value_select=excluded.value_select, updated_at=excluded.updated_at
             WHERE excluded.updated_at >= updated_at",
        )
        .bind(&val.id).bind(&val.row_id).bind(&val.property_id)
        .bind(&val.value_text).bind(val.value_number).bind(val.value_date)
        .bind(val.value_bool).bind(&val.value_select)
        .bind(val.created_at).bind(val.updated_at)
        .execute(&state.db).await?;
        accepted.database_property_values.push(val.id);
    }

    state.broadcast_sync_complete().await;

    Ok(Json(SyncPushResponse {
        server_time: now_millis(),
        accepted,
        rejected,
    }))
}
