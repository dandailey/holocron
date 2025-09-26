# Holocron Web Server Guide

The Holocron server exposes a local HTTP API to inspect and manipulate holocrons programmatically.

## TL;DR

- `holo server start [--host HOST] [--port PORT]` — Start the server
- `holo server status` — Server status (placeholder)
- `holo server stop` — Stop the server (not yet implemented; Ctrl+C)
- Endpoints root: `http://HOST:PORT/v1/`
- Registry endpoint: `GET /v1/holocrons`
- Holo help endpoint: `GET /v1/{holo}/help`
- Operations API under: `/v1/{holo}/ops/*`

## Getting Started

```bash
holo list
holo select my-holo
holo server start --host 0.0.0.0 --port 8080
# Visit http://localhost:8080/v1/holocrons
```

If you’re not inside a holocron directory, the server still works: it reads the registry and serves all registered holos.

## Key Endpoints

- `GET /v1/holocrons` — List registered holocrons and defaults
- `GET /v1/{holo}/status` — Health/status for a holocron
- `GET /v1/{holo}/help` — Markdown help for Operations API
- Operations API (see details below):
  - `GET|POST /v1/{holo}/ops/list_files`
  - `GET /v1/{holo}/ops/read_file`
  - `POST /v1/{holo}/ops/search`
  - `PUT /v1/{holo}/ops/put_file`
  - `DELETE /v1/{holo}/ops/delete_file`
  - `POST /v1/{holo}/ops/move_file`
  - `POST /v1/{holo}/ops/bundle`

## Operations API Summary

- Paths are sandboxed within the holocron root.
- `if_match_sha256` protects writes with preconditions.
- JSON request bodies with `Content-Type: application/json`.
- Query params supported for GET.

## Examples

List files (first 5):
```bash
curl -s "http://localhost:4567/v1/my-holo/ops/list_files?limit=5"
```

Read a file:
```bash
curl -s "http://localhost:4567/v1/my-holo/ops/read_file?path=README.md"
```

Search with context lines:
```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"query":"memory","before":1,"after":1}' \
  "http://localhost:4567/v1/my-holo/ops/search"
```

Safe write with precondition:
```bash
sha=$(curl -s "http://localhost:4567/v1/my-holo/ops/read_file?path=docs/demo.md" | jq -r .sha256)
curl -s -X PUT -H "Content-Type: application/json" \
  -d '{"path":"docs/demo.md","content":"Hello world","if_match_sha256":"'"$sha"'"}' \
  "http://localhost:4567/v1/my-holo/ops/put_file"
```

Delete a file:
```bash
curl -s -X DELETE -H "Content-Type: application/json" \
  -d '{"path":"docs/demo.md"}' \
  "http://localhost:4567/v1/my-holo/ops/delete_file"
```

## Troubleshooting

- Port in use: change with `--port`.
- No holocrons listed: run `holo list` and `holo register` / `holo init`.
- 404s for `{holo}`: ensure it exists and the path is valid.

## Design Notes

- Backed by WEBrick; lightweight and local.
- Uses `OperationsHandler` to perform file ops.
- See `.holocron/sync/web_service_plan.md` for detailed design.

