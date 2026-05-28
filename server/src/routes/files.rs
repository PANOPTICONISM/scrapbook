use axum::{
    body::Bytes,
    extract::{Path, State},
    http::{header, HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde_json::{json, Value};
use std::sync::Arc;
use uuid::Uuid;

use crate::{
    auth::AuthToken,
    error::{AppError, Result},
    AppState,
};

const ALLOWED_MIME: &[&str] = &[
    "image/png",
    "image/jpeg",
    "image/gif",
    "image/webp",
    "image/svg+xml",
];

/// Upload raw image bytes (Content-Type header sets the mime). Returns its id.
pub async fn upload_file(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    body: Bytes,
) -> Result<(StatusCode, Json<Value>)> {
    let mime = headers
        .get(header::CONTENT_TYPE)
        .and_then(|v| v.to_str().ok())
        .map(|s| s.split(';').next().unwrap_or(s).trim().to_string())
        .unwrap_or_default();

    if !ALLOWED_MIME.contains(&mime.as_str()) {
        return Err(AppError::BadRequest("unsupported file type".into()));
    }
    if body.is_empty() {
        return Err(AppError::BadRequest("empty body".into()));
    }

    let id = Uuid::new_v4().to_string();
    let dir = &state.config.files_dir;
    tokio::fs::create_dir_all(dir)
        .await
        .map_err(|e| AppError::Internal(e.into()))?;
    let path = std::path::Path::new(dir).join(&id);
    tokio::fs::write(&path, &body)
        .await
        .map_err(|e| AppError::Internal(e.into()))?;

    let now = chrono_millis();
    sqlx::query("INSERT INTO files (id, mime, size, created_at) VALUES (?, ?, ?, ?)")
        .bind(&id)
        .bind(&mime)
        .bind(body.len() as i64)
        .bind(now)
        .execute(&state.db)
        .await?;

    Ok((StatusCode::CREATED, Json(json!({ "id": id }))))
}

/// Serve a file's bytes with its stored mime type.
pub async fn get_file(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
) -> Result<Response> {
    let mime: Option<String> = sqlx::query_scalar("SELECT mime FROM files WHERE id = ?")
        .bind(&id)
        .fetch_optional(&state.db)
        .await?;
    let mime = mime.ok_or(AppError::NotFound)?;

    let path = std::path::Path::new(&state.config.files_dir).join(&id);
    let bytes = tokio::fs::read(&path)
        .await
        .map_err(|_| AppError::NotFound)?;

    Ok((
        [
            (header::CONTENT_TYPE, mime),
            (header::CACHE_CONTROL, "public, max-age=31536000, immutable".into()),
        ],
        bytes,
    )
        .into_response())
}

fn chrono_millis() -> i64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}
