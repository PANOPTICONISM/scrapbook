use serde::{Deserialize, Serialize};

use super::{
    block::Block,
    database::{DatabaseProperty, DatabasePropertyValue, DatabaseRow},
    page::Page,
};

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Tombstone {
    pub entity_type: String,
    pub entity_id: String,
    pub deleted_at: i64,
}

#[derive(Debug, Serialize)]
pub struct SyncPullResponse {
    pub server_time: i64,
    pub pages: Vec<Page>,
    pub blocks: Vec<Block>,
    pub database_properties: Vec<DatabaseProperty>,
    pub database_rows: Vec<DatabaseRow>,
    pub database_property_values: Vec<DatabasePropertyValue>,
    pub tombstones: Vec<Tombstone>,
}

#[derive(Debug, Deserialize)]
pub struct SyncPushRequest {
    #[serde(default)]
    pub pages: Vec<Page>,
    #[serde(default)]
    pub blocks: Vec<Block>,
    #[serde(default)]
    pub database_properties: Vec<DatabaseProperty>,
    #[serde(default)]
    pub database_rows: Vec<DatabaseRow>,
    #[serde(default)]
    pub database_property_values: Vec<DatabasePropertyValue>,
}

#[derive(Debug, Serialize)]
pub struct SyncPushResponse {
    pub server_time: i64,
    pub accepted: AcceptedIds,
    pub rejected: RejectedRecords,
}

#[derive(Debug, Serialize, Default)]
pub struct AcceptedIds {
    pub pages: Vec<String>,
    pub blocks: Vec<String>,
    pub database_properties: Vec<String>,
    pub database_rows: Vec<String>,
    pub database_property_values: Vec<String>,
}

#[derive(Debug, Serialize, Default)]
pub struct RejectedRecords {
    pub pages: Vec<RejectedItem<Page>>,
    pub blocks: Vec<RejectedItem<Block>>,
}

#[derive(Debug, Serialize)]
pub struct RejectedItem<T> {
    pub id: String,
    pub reason: String,
    pub server_record: T,
}
