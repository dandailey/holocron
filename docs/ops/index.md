# Operations Parity Matrix

This page lists all supported operations and where they are available. CLI and HTTP share the same parameter names,
request/response shapes, and error semantics unless marked otherwise.

## Surfaces
- CLI: `holo ops <operation> [--flags...]`
- HTTP: `/v1/{holo}/ops/<operation>`

## Parity

| Operation       | CLI | HTTP | Notes |
|-----------------|-----|------|-------|
| list_files      | ✅  | ✅   | Shared list filters documented below |
| read_file       | ✅  | ✅   | GET with query params |
| search          | ✅  | ✅   | POST body for complex queries |
| put_file        | ✅  | ✅   | PUT with JSON; supports `if_match_sha256` |
| delete_file     | ✅  | ✅   | DELETE with JSON; supports `if_match_sha256` |
| move_file       | ✅  | ✅   | POST with JSON; supports `overwrite` |
| bundle          | ✅  | ✅   | POST returns combined content/metadata |
| apply_diff      | ✅  | ✅   | POST with unified diff content |
| server_start    | ✅  | —    | CLI-only (host concern) |
| server_stop     | ✅  | —    | CLI-only (host concern) |
| server_status   | ✅  | —    | CLI-only (host concern) |

## Shared List Filters

These filters apply to list-like operations (e.g., `list_files`). When present, both surfaces accept the same names.

- `dir` (string, default `.`)
- `include_glob[]` (repeatable) — patterns to include
- `exclude_glob[]` (repeatable) — patterns to exclude
- `extensions[]` (repeatable) — e.g., `md`, `rb`
- `max_depth` (integer)
- `sort` (`path|mtime|size`, default `path`)
- `order` (`asc|desc`, default `asc`)
- `limit` (integer)
- `offset` (integer)

CLI arrays use repeated flags; HTTP arrays use repeated query params.

```bash
holo ops list_files --include-glob "**/*.md" --include-glob "**/*.rb" --limit 10
# HTTP
GET /v1/{holo}/ops/list_files?include_glob=**/*.md&include_glob=**/*.rb&limit=10
```

## Error Envelope

All errors are returned in the same envelope:

```json
{ "error": "message", "details": {"field":"info"}, "status": 400 }
```

Standard codes: 400 bad input, 403 sandbox/path policy, 404 missing, 405 method, 409 conflict, 412 precondition failed,
500 internal error.

## Idempotency & Preconditions

Write operations accept `if_match_sha256` to guard against accidental overwrites. On mismatch, return HTTP 412 with the
error envelope above.


