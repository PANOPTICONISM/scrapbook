use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};
use std::sync::Arc;

use crate::{
    auth::AuthToken,
    error::{AppError, Result},
    models::block::*,
    AppState,
};

pub async fn list_blocks(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(page_id): Path<String>,
) -> Result<Json<Value>> {
    let blocks = sqlx::query_as::<_, Block>(
        "SELECT * FROM blocks WHERE page_id = ? AND deleted_at IS NULL ORDER BY position ASC",
    )
    .bind(&page_id)
    .fetch_all(&state.db)
    .await?;

    Ok(Json(json!({ "blocks": blocks })))
}

pub async fn create_block(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Json(req): Json<CreateBlockRequest>,
) -> Result<(StatusCode, Json<Value>)> {
    let block_type = req.block_type.unwrap_or_else(|| "markdown".to_string());
    let content = req.content.unwrap_or_default();
    let position = req.position.unwrap_or(1.0);

    sqlx::query(
        "INSERT INTO blocks (id, page_id, type, content, position, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)",
    )
    .bind(&req.id)
    .bind(&req.page_id)
    .bind(&block_type)
    .bind(&content)
    .bind(position)
    .bind(req.created_at)
    .bind(req.updated_at)
    .execute(&state.db)
    .await?;

    let block = sqlx::query_as::<_, Block>("SELECT * FROM blocks WHERE id = ?")
        .bind(&req.id)
        .fetch_one(&state.db)
        .await?;

    state.notify_change("block", &req.id, req.updated_at).await;

    Ok((StatusCode::CREATED, Json(json!({ "block": block }))))
}

pub async fn update_block(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
    Json(req): Json<UpdateBlockRequest>,
) -> Result<Json<Value>> {
    sqlx::query(
        "UPDATE blocks SET
            content    = COALESCE(?, content),
            position   = COALESCE(?, position),
            updated_at = ?
         WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(&req.content)
    .bind(req.position)
    .bind(req.updated_at)
    .bind(&id)
    .execute(&state.db)
    .await?;

    let block = sqlx::query_as::<_, Block>(
        "SELECT * FROM blocks WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(&id)
    .fetch_optional(&state.db)
    .await?
    .ok_or(AppError::NotFound)?;

    state.notify_change("block", &id, req.updated_at).await;

    Ok(Json(json!({ "block": block })))
}

pub async fn delete_block(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
) -> Result<StatusCode> {
    let now = super::pages::now_millis();
    sqlx::query(
        "UPDATE blocks SET deleted_at = ?, updated_at = ? WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(now)
    .bind(now)
    .bind(&id)
    .execute(&state.db)
    .await?;

    state.notify_change("block", &id, now).await;
    Ok(StatusCode::NO_CONTENT)
}
