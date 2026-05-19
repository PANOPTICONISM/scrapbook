# Stage 1: Build
FROM rust:1.78-slim AS builder

RUN apt-get update && apt-get install -y musl-tools libssl-dev pkg-config && rm -rf /var/lib/apt/lists/*

RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /app

# Cache dependencies by building with a stub main first
COPY server/Cargo.toml server/Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release --target x86_64-unknown-linux-musl
RUN rm -rf src

# Build the real binary
COPY server/src ./src
RUN touch src/main.rs && cargo build --release --target x86_64-unknown-linux-musl

# Stage 2: Minimal runtime image
FROM alpine:3.19

RUN apk add --no-cache ca-certificates

WORKDIR /data

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/scrapbook-server /usr/local/bin/scrapbook-server

EXPOSE 8080
VOLUME ["/data"]

ENV DATABASE_URL="sqlite:/data/scrapbook.db"
ENV HOST="0.0.0.0"
ENV PORT="8080"

CMD ["scrapbook-server"]
