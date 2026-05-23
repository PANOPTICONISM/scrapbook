mod auth;
mod cleanup;
mod config;
mod error;
mod models;
mod routes;

use axum::{
    routing::{delete, get, patch, post},
    Router,
};
use sqlx::sqlite::{SqliteConnectOptions, SqlitePoolOptions};
use std::{net::SocketAddr, str::FromStr, sync::Arc};
use tokio::sync::broadcast;
use tower_http::{cors::CorsLayer, trace::TraceLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use config::Config;
use routes::{blocks, databases, pages, sync, ws};

pub struct AppState {
    pub db: sqlx::SqlitePool,
    pub config: Arc<Config>,
    pub ws_tx: broadcast::Sender<String>,
}

impl AppState {
    pub async fn notify_change(&self, entity: &str, id: &str, updated_at: i64) {
        let msg = format!(
            r#"{{"type":"change","entity":"{entity}","id":"{id}","updated_at":{updated_at}}}"#
        );
        let _ = self.ws_tx.send(msg);
    }

    pub async fn broadcast_sync_complete(&self) {
        let _ = self.ws_tx.send(r#"{"type":"sync_complete"}"#.to_string());
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "scrapbook_server=debug,tower_http=info".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let config = Config::from_env()?;
    tracing::info!("Starting scrapbook server on {}:{}", config.host, config.port);

    let opts = SqliteConnectOptions::from_str(&config.database_url)?
        .create_if_missing(true)
        .journal_mode(sqlx::sqlite::SqliteJournalMode::Wal)
        .foreign_keys(true);

    let db = SqlitePoolOptions::new()
        .max_connections(5)
        .connect_with(opts)
        .await?;

    sqlx::migrate!("./src/migrations").run(&db).await?;
    tracing::info!("Database migrations applied");

    let (ws_tx, _) = broadcast::channel(64);

    let state = Arc::new(AppState {
        db,
        config: Arc::new(config.clone()),
        ws_tx,
    });

    cleanup::spawn(state.clone());

    let app = Router::new()
        .route("/api/health", get(|| async { "ok" }))
        .route("/api/pages", get(pages::list_pages).post(pages::create_page))
        .route("/api/pages/{id}", get(pages::get_page).patch(pages::update_page).delete(pages::delete_page))
        .route("/api/pages/{page_id}/blocks", get(blocks::list_blocks))
        .route("/api/blocks", post(blocks::create_block))
        .route("/api/blocks/{id}", patch(blocks::update_block).delete(blocks::delete_block))
        .route("/api/databases/{id}/properties", get(databases::list_properties).post(databases::create_property))
        .route("/api/databases/{id}/properties/{prop_id}", patch(databases::update_property).delete(databases::delete_property))
        .route("/api/databases/{id}/rows", get(databases::list_rows).post(databases::create_row))
        .route("/api/databases/{id}/rows/{row_id}", delete(databases::delete_row))
        .route("/api/rows/{row_id}/values", get(databases::list_values).post(databases::upsert_value))
        .route("/api/sync", get(sync::pull).post(sync::push))
        .route("/api/ws", get(ws::ws_handler))
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let addr: SocketAddr = format!("{}:{}", config.host, config.port).parse()?;
    let listener = tokio::net::TcpListener::bind(addr).await?;
    tracing::info!("Listening on {addr}");

    axum::serve(listener, app).await?;
    Ok(())
}
