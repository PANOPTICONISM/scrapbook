use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    response::Response,
};
use futures::{SinkExt, StreamExt};
use std::sync::Arc;
use tokio::time::{interval, Duration};

use crate::{auth::AuthToken, AppState};

pub async fn ws_handler(
    _auth: AuthToken,
    ws: WebSocketUpgrade,
    State(state): State<Arc<AppState>>,
) -> Response {
    ws.on_upgrade(move |socket| handle_socket(socket, state))
}

async fn handle_socket(socket: WebSocket, state: Arc<AppState>) {
    let (mut sender, mut receiver) = socket.split();
    let mut rx = state.ws_tx.subscribe();

    let mut ping_interval = interval(Duration::from_secs(30));

    loop {
        tokio::select! {
            // Broadcast message from server (change notification)
            Ok(msg) = rx.recv() => {
                if sender.send(Message::Text(msg.into())).await.is_err() {
                    break;
                }
            }
            // Ping keepalive
            _ = ping_interval.tick() => {
                let ping = r#"{"type":"ping"}"#;
                if sender.send(Message::Text(ping.into())).await.is_err() {
                    break;
                }
            }
            // Incoming message from client (pong only)
            msg = receiver.next() => {
                match msg {
                    Some(Ok(Message::Text(_))) => { /* pong received, do nothing */ }
                    Some(Ok(Message::Close(_))) | None => break,
                    _ => {}
                }
            }
        }
    }
}
