use axum::extract::FromRequestParts;
use axum::http::{request::Parts, HeaderMap};
use std::sync::Arc;

use crate::{AppState, error::AppError};

pub struct AuthToken;

impl FromRequestParts<Arc<AppState>> for AuthToken {
    type Rejection = AppError;

    async fn from_request_parts(parts: &mut Parts, state: &Arc<AppState>) -> Result<Self, Self::Rejection> {
        let config = &state.config;

        let token = bearer_token(&parts.headers).or_else(|| query_token(parts.uri.query()));

        match token {
            Some(t) if constant_time_eq(t.as_bytes(), config.api_token.as_bytes()) => Ok(AuthToken),
            _ => Err(AppError::Unauthorized),
        }
    }
}

fn bearer_token(headers: &HeaderMap) -> Option<String> {
    headers
        .get("authorization")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "))
        .map(|s| s.to_string())
}

fn query_token(query: Option<&str>) -> Option<String> {
    query?.split('&').find_map(|kv| {
        let mut parts = kv.splitn(2, '=');
        match (parts.next(), parts.next()) {
            (Some("token"), Some(v)) => Some(v.to_string()),
            _ => None,
        }
    })
}

fn constant_time_eq(a: &[u8], b: &[u8]) -> bool {
    if a.len() != b.len() {
        return false;
    }
    a.iter().zip(b.iter()).fold(0u8, |acc, (x, y)| acc | (x ^ y)) == 0
}
