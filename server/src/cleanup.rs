//! Periodic cleanup of soft-deleted records. Pages that have been in trash
//! longer than [`TRASH_TTL_MS`] are hard-deleted (with tombstones), so other
//! clients can also remove them on their next sync pull.
//!
//! Restoring a page clears `deleted_at`, so it's safe from cleanup.

use std::sync::Arc;
use std::time::Duration;
use tokio::time::interval;

use crate::routes::pages::{hard_delete_page, now_millis};
use crate::AppState;

/// Trash items live this long before being permanently deleted.
pub const TRASH_TTL_MS: i64 = 30 * 24 * 60 * 60 * 1000; // 30 days

/// How often the cleanup task runs.
pub const CLEANUP_INTERVAL: Duration = Duration::from_secs(24 * 60 * 60); // 24 hours

pub fn spawn(state: Arc<AppState>) {
    tokio::spawn(async move {
        // Run once on startup so server restarts always catch up.
        if let Err(e) = run_once(&state).await {
            tracing::warn!("trash cleanup failed at startup: {e}");
        }

        let mut ticker = interval(CLEANUP_INTERVAL);
        // Skip the immediate first tick — we just ran.
        ticker.tick().await;
        loop {
            ticker.tick().await;
            if let Err(e) = run_once(&state).await {
                tracing::warn!("trash cleanup failed: {e}");
            }
        }
    });
}

async fn run_once(state: &Arc<AppState>) -> anyhow::Result<()> {
    let now = now_millis();
    let cutoff = now - TRASH_TTL_MS;

    let expired_ids: Vec<String> = sqlx::query_scalar(
        "SELECT id FROM pages WHERE deleted_at IS NOT NULL AND deleted_at < ?",
    )
    .bind(cutoff)
    .fetch_all(&state.db)
    .await?;

    if expired_ids.is_empty() {
        return Ok(());
    }

    tracing::info!("cleanup: hard-deleting {} expired page(s)", expired_ids.len());
    for id in &expired_ids {
        if let Err(e) = hard_delete_page(state, id, now).await {
            tracing::warn!("failed to hard-delete page {id}: {e}");
        }
    }
    Ok(())
}
