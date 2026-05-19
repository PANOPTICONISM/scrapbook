use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};
use std::sync::Arc;

use crate::{
    auth::AuthToken,
    error::Result,
    models::database::*,
    AppState,
};

use super::pages::now_millis;

// --- Properties ---

pub async fn list_properties(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(db_id): Path<String>,
) -> Result<Json<Value>> {
    let props = sqlx::query_as::<_, DatabaseProperty>(
        "SELECT * FROM database_properties WHERE database_id = ? AND deleted_at IS NULL ORDER BY position ASC",
    )
    .bind(&db_id)
    .fetch_all(&state.db)
    .await?;

    Ok(Json(json!({ "properties": props })))
}

pub async fn create_property(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(db_id): Path<String>,
    Json(req): Json<CreatePropertyRequest>,
) -> Result<(StatusCode, Json<Value>)> {
    let position = req.position.unwrap_or(1.0);

    sqlx::query(
        "INSERT INTO database_properties (id, database_id, name, type, options, position, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
    )
    .bind(&req.id)
    .bind(&db_id)
    .bind(&req.name)
    .bind(&req.prop_type)
    .bind(&req.options)
    .bind(position)
    .bind(req.created_at)
    .bind(req.updated_at)
    .execute(&state.db)
    .await?;

    let prop = sqlx::query_as::<_, DatabaseProperty>(
        "SELECT * FROM database_properties WHERE id = ?",
    )
    .bind(&req.id)
    .fetch_one(&state.db)
    .await?;

    Ok((StatusCode::CREATED, Json(json!({ "property": prop }))))
}

pub async fn update_property(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path((_db_id, prop_id)): Path<(String, String)>,
    Json(req): Json<UpdatePropertyRequest>,
) -> Result<Json<Value>> {
    sqlx::query(
        "UPDATE database_properties SET
            name       = COALESCE(?, name),
            options    = COALESCE(?, options),
            position   = COALESCE(?, position),
            updated_at = ?
         WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(&req.name)
    .bind(&req.options)
    .bind(req.position)
    .bind(req.updated_at)
    .bind(&prop_id)
    .execute(&state.db)
    .await?;

    let prop = sqlx::query_as::<_, DatabaseProperty>(
        "SELECT * FROM database_properties WHERE id = ?",
    )
    .bind(&prop_id)
    .fetch_one(&state.db)
    .await?;

    Ok(Json(json!({ "property": prop })))
}

pub async fn delete_property(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path((_db_id, prop_id)): Path<(String, String)>,
) -> Result<StatusCode> {
    let now = now_millis();
    sqlx::query(
        "UPDATE database_properties SET deleted_at = ?, updated_at = ? WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(now)
    .bind(now)
    .bind(&prop_id)
    .execute(&state.db)
    .await?;

    Ok(StatusCode::NO_CONTENT)
}

// --- Rows ---

pub async fn list_rows(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(db_id): Path<String>,
) -> Result<Json<Value>> {
    let rows = sqlx::query_as::<_, DatabaseRow>(
        "SELECT * FROM database_rows WHERE database_id = ? AND deleted_at IS NULL ORDER BY position ASC",
    )
    .bind(&db_id)
    .fetch_all(&state.db)
    .await?;

    let properties = sqlx::query_as::<_, DatabaseProperty>(
        "SELECT * FROM database_properties WHERE database_id = ? AND deleted_at IS NULL ORDER BY position ASC",
    )
    .bind(&db_id)
    .fetch_all(&state.db)
    .await?;

    Ok(Json(json!({ "rows": rows, "properties": properties })))
}

pub async fn create_row(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(db_id): Path<String>,
    Json(req): Json<CreateRowRequest>,
) -> Result<(StatusCode, Json<Value>)> {
    let position = req.position.unwrap_or(1.0);

    // Create the linked page for this row
    let page_id = &req.page_id;
    sqlx::query(
        "INSERT INTO pages (id, title, is_database, position, created_at, updated_at)
         VALUES (?, '', 0, 1.0, ?, ?)",
    )
    .bind(page_id)
    .bind(req.created_at)
    .bind(req.updated_at)
    .execute(&state.db)
    .await?;

    sqlx::query(
        "INSERT INTO database_rows (id, database_id, page_id, position, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?)",
    )
    .bind(&req.id)
    .bind(&db_id)
    .bind(page_id)
    .bind(position)
    .bind(req.created_at)
    .bind(req.updated_at)
    .execute(&state.db)
    .await?;

    let row = sqlx::query_as::<_, DatabaseRow>("SELECT * FROM database_rows WHERE id = ?")
        .bind(&req.id)
        .fetch_one(&state.db)
        .await?;

    Ok((StatusCode::CREATED, Json(json!({ "row": row }))))
}

pub async fn delete_row(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path((_db_id, row_id)): Path<(String, String)>,
) -> Result<StatusCode> {
    let now = now_millis();
    sqlx::query(
        "UPDATE database_rows SET deleted_at = ?, updated_at = ? WHERE id = ? AND deleted_at IS NULL",
    )
    .bind(now)
    .bind(now)
    .bind(&row_id)
    .execute(&state.db)
    .await?;

    Ok(StatusCode::NO_CONTENT)
}

// --- Property Values ---

pub async fn list_values(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(row_id): Path<String>,
) -> Result<Json<Value>> {
    let values = sqlx::query_as::<_, DatabasePropertyValue>(
        "SELECT * FROM database_property_values WHERE row_id = ?",
    )
    .bind(&row_id)
    .fetch_all(&state.db)
    .await?;

    Ok(Json(json!({ "values": values })))
}

pub async fn upsert_value(
    _auth: AuthToken,
    State(state): State<Arc<AppState>>,
    Path(row_id): Path<String>,
    Json(req): Json<UpsertPropertyValueRequest>,
) -> Result<Json<Value>> {
    sqlx::query(
        "INSERT INTO database_property_values
            (id, row_id, property_id, value_text, value_number, value_date, value_bool, value_select, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
         ON CONFLICT(row_id, property_id) DO UPDATE SET
            value_text   = excluded.value_text,
            value_number = excluded.value_number,
            value_date   = excluded.value_date,
            value_bool   = excluded.value_bool,
            value_select = excluded.value_select,
            updated_at   = excluded.updated_at",
    )
    .bind(&req.id)
    .bind(&row_id)
    .bind(&req.property_id)
    .bind(&req.value_text)
    .bind(req.value_number)
    .bind(req.value_date)
    .bind(req.value_bool)
    .bind(&req.value_select)
    .bind(req.created_at)
    .bind(req.updated_at)
    .execute(&state.db)
    .await?;

    let value = sqlx::query_as::<_, DatabasePropertyValue>(
        "SELECT * FROM database_property_values WHERE row_id = ? AND property_id = ?",
    )
    .bind(&row_id)
    .bind(&req.property_id)
    .fetch_one(&state.db)
    .await?;

    Ok(Json(json!({ "value": value })))
}
