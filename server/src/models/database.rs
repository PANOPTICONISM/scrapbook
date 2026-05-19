use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct DatabaseProperty {
    pub id: String,
    pub database_id: String,
    pub name: String,
    #[serde(rename = "type")]
    #[sqlx(rename = "type")]
    pub prop_type: String,
    pub options: Option<String>,
    pub position: f64,
    pub created_at: i64,
    pub updated_at: i64,
    pub deleted_at: Option<i64>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct DatabaseRow {
    pub id: String,
    pub database_id: String,
    pub page_id: String,
    pub position: f64,
    pub created_at: i64,
    pub updated_at: i64,
    pub deleted_at: Option<i64>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct DatabasePropertyValue {
    pub id: String,
    pub row_id: String,
    pub property_id: String,
    pub value_text: Option<String>,
    pub value_number: Option<f64>,
    pub value_date: Option<i64>,
    pub value_bool: Option<bool>,
    pub value_select: Option<String>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct CreatePropertyRequest {
    pub id: String,
    pub name: String,
    #[serde(rename = "type")]
    pub prop_type: String,
    pub options: Option<String>,
    pub position: Option<f64>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct UpdatePropertyRequest {
    pub name: Option<String>,
    pub options: Option<String>,
    pub position: Option<f64>,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct CreateRowRequest {
    pub id: String,
    pub page_id: String,
    pub position: Option<f64>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct UpsertPropertyValueRequest {
    pub id: String,
    pub property_id: String,
    pub value_text: Option<String>,
    pub value_number: Option<f64>,
    pub value_date: Option<i64>,
    pub value_bool: Option<bool>,
    pub value_select: Option<String>,
    pub created_at: i64,
    pub updated_at: i64,
}
