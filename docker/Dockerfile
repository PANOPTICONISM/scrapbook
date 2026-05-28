# syntax=docker/dockerfile:1

# ---- Build the Rust server ----
FROM rust:1-slim-bookworm AS builder

WORKDIR /app

COPY server/Cargo.toml server/Cargo.lock ./
RUN mkdir src \
    && echo "fn main() {}" > src/main.rs \
    && cargo build --release \
    && rm -rf src

COPY server/src ./src
RUN touch src/main.rs && cargo build --release

# ---- Build the Flutter web app (the PWA) ----
FROM ghcr.io/cirruslabs/flutter:3.44.0 AS web

WORKDIR /app
COPY app/ ./
RUN flutter pub get && flutter build web --release

# ---- Runtime: one server hosting both the API and the web app ----
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY --from=builder /app/target/release/scrapbook-server /usr/local/bin/scrapbook-server
COPY --from=web /app/build/web /srv/web

ENV DATABASE_URL="sqlite:/data/scrapbook.db" \
    HOST="0.0.0.0" \
    PORT="47291" \
    STATIC_DIR="/srv/web"

EXPOSE ${PORT}
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT}/api/health" || exit 1

CMD ["scrapbook-server"]
