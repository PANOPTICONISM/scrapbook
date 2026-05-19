use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Page {
    pub id: String,
    pub parent_id: Option<String>,
    pub title: String,
    pub icon: Option<String>,
    pub is_database: bool,
    pub position: f64,
    pub created_at: i64,
    pub updated_at: i64,
    pub deleted_at: Option<i64>,
}

#[derive(Debug, Deserialize)]
pub struct CreatePageRequest {
    pub id: String,
    pub parent_id: Option<String>,
    pub title: Option<String>,
    pub icon: Option<String>,
    pub is_database: Option<bool>,
    pub position: Option<f64>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct UpdatePageRequest {
    pub parent_id: Option<String>,
    pub title: Option<String>,
    pub icon: Option<String>,
    pub position: Option<f64>,
    pub updated_at: i64,
}
