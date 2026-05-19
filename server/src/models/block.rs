use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Block {
    pub id: String,
    pub page_id: String,
    #[serde(rename = "type")]
    #[sqlx(rename = "type")]
    pub block_type: String,
    pub content: String,
    pub position: f64,
    pub created_at: i64,
    pub updated_at: i64,
    pub deleted_at: Option<i64>,
}

#[derive(Debug, Deserialize)]
pub struct CreateBlockRequest {
    pub id: String,
    pub page_id: String,
    #[serde(rename = "type")]
    pub block_type: Option<String>,
    pub content: Option<String>,
    pub position: Option<f64>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct UpdateBlockRequest {
    pub content: Option<String>,
    pub position: Option<f64>,
    pub updated_at: i64,
}
