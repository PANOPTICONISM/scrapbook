# Deploying the Scrapbook server

The server is a single Rust binary that stores the whole vault in one SQLite
file. Everything it needs is in this folder.

## 1. Set a token

```bash
cd docker
cp .env.example .env
# edit .env and set SCRAPBOOK_TOKEN to a long random string, e.g.:
#   openssl rand -hex 32
```

`SCRAPBOOK_TOKEN` is the shared secret the Flutter app must send on every
request. Treat it like a password.

## 2. Build and run

```bash
docker compose up -d --build
```

First build compiles the Rust binary, so it takes a few minutes. Subsequent
builds reuse the cached dependency layer.

Check it's healthy:

```bash
docker compose ps          # STATUS should show "healthy"
curl http://localhost:47291/api/health   # -> ok
```

## 3. Point the app at it

In the app's setup screen enter:

- **Server URL:** `http://<server-host>:47291`
- **API token:** the same `SCRAPBOOK_TOKEN` value

## Data & backups

The vault lives in `docker/data/scrapbook.db` on the host (bind-mounted to
`/data` in the container). To back up, stop the container and copy the `data/`
folder, or copy the `.db` file while the server is idle:

```bash
docker compose stop
cp -r data ../backups/$(date +%F)
docker compose start
```

Migrations run automatically on startup.
