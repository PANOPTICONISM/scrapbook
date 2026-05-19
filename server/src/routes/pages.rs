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
    models::{block::Block, page::*},
    AppState,
};

pub async fn list_pages(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>> {
    let pages = sqlx::query_as::<_, Page>(
        "SELECT * FROM pages WHERE deleted_at IS NULL ORDER BY position ASC",
    )
    .fetch_all(&state.db)
    .await?;

    Ok(Json(json!({ "pages": pages })))
}

pub async fn get_page(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
) -> Result<Json<Value>> {
    let page = sqlx::query_as::<_, Page>(
        "SELECT * FROM pages WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(&id)
    .fetch_optional(&state.db)
    .await?
    .ok_or(AppError::NotFound)?;

    let blocks = sqlx::query_as::<_, Block>(
        "SELECT * FROM blocks WHERE page_id = ? AND deleted_at IS NULL ORDER BY position ASC",
    )
    .bind(&id)
    .fetch_all(&state.db)
    .await?;

    Ok(Json(json!({ "page": page, "blocks": blocks })))
}

pub async fn create_page(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Json(req): Json<CreatePageRequest>,
) -> Result<(StatusCode, Json<Value>)> {
    let is_database = req.is_database.unwrap_or(false) as i64;
    let position = req.position.unwrap_or(1.0);
    let title = req.title.unwrap_or_default();

    sqlx::query(
        "INSERT INTO pages (id, parent_id, title, icon, is_database, position, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
    )
    .bind(&req.id)
    .bind(&req.parent_id)
    .bind(&title)
    .bind(&req.icon)
    .bind(is_database)
    .bind(position)
    .bind(req.created_at)
    .bind(req.updated_at)
    .execute(&state.db)
    .await?;

    // Auto-create a blank markdown block for regular (non-database) pages
    if !req.is_database.unwrap_or(false) {
        let block_id = uuid::Uuid::new_v4().to_string();
        sqlx::query(
            "INSERT INTO blocks (id, page_id, type, content, position, created_at, updated_at)
             VALUES (?, ?, 'markdown', '', 1.0, ?, ?)",
        )
        .bind(&block_id)
        .bind(&req.id)
        .bind(req.created_at)
        .bind(req.updated_at)
        .execute(&state.db)
        .await?;
    }

    let page = sqlx::query_as::<_, Page>("SELECT * FROM pages WHERE id = ?")
        .bind(&req.id)
        .fetch_one(&state.db)
        .await?;

    state.notify_change("page", &req.id, req.updated_at).await;

    Ok((StatusCode::CREATED, Json(json!({ "page": page }))))
}

pub async fn update_page(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
    Json(req): Json<UpdatePageRequest>,
) -> Result<Json<Value>> {
    sqlx::query(
        "UPDATE pages SET
            parent_id  = COALESCE(?, parent_id),
            title      = COALESCE(?, title),
            icon       = COALESCE(?, icon),
            position   = COALESCE(?, position),
            updated_at = ?
         WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(&req.parent_id)
    .bind(&req.title)
    .bind(&req.icon)
    .bind(req.position)
    .bind(req.updated_at)
    .bind(&id)
    .execute(&state.db)
    .await?;

    let page = sqlx::query_as::<_, Page>(
        "SELECT * FROM pages WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(&id)
    .fetch_optional(&state.db)
    .await?
    .ok_or(AppError::NotFound)?;

    state.notify_change("page", &id, req.updated_at).await;

    Ok(Json(json!({ "page": page })))
}

pub async fn delete_page(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
) -> Result<StatusCode> {
    let now = now_millis();
    sqlx::query(
        "UPDATE pages SET deleted_at = ?, updated_at = ? WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(now)
    .bind(now)
    .bind(&id)
    .execute(&state.db)
    .await?;

    state.notify_change("page", &id, now).await;
    Ok(StatusCode::NO_CONTENT)
}

pub fn now_millis() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as i64
}
