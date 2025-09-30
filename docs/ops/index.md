# Operations Parity Matrix

This page lists all supported operations and where they are available. CLI and HTTP share the same parameter names,
request/response shapes, and error semantics unless marked otherwise.

## API-Only Architecture

Holocron enforces a **strict separation** between system content and user files:

- **System Content** (API-only): Progress logs, decisions, context refreshes, system docs (vision, roadmap, etc.) are accessed ONLY through resource operations. Generic file operations are blocked.
- **User Files** (`files/` directory): Generic file operations (read_file, put_file, delete_file, move_file, search, bundle, apply_diff) are allowed ONLY under the `files/` directory.

**Why:** This architecture provides stability, prevents drift, enables deterministic upgrades, and creates a contract that both CLI and HTTP clients can rely on.

**Policy:** Any attempt to use generic file operations on system paths returns HTTP 403 with the message: "Use resource ops or paths under files/."

## Surfaces
- CLI: `holo ops <operation> [--flags...]`
- HTTP: `/v1/{holo}/ops/<operation>`

## Parity

### Generic File Operations (files/ only)

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

### Resource Operations (system content)

| Operation       | CLI | HTTP | Notes |
|-----------------|-----|------|-------|
| doc_get         | ✅  | ✅   | Get system document (vision, roadmap, project_overview, commands) |
| doc_update      | ✅  | ✅   | Update or create system document |
| progress_add    | ✅  | ✅   | Add progress log entry |
| progress_list   | ✅  | ✅   | List progress entries with pagination |
| decision_add    | ✅  | ✅   | Add decision log entry |
| decision_list   | ✅  | ✅   | List decision entries with pagination |
| refresh_create  | ✅  | ✅   | Create context refresh file |
| refresh_list    | ✅  | ✅   | List context refresh files |
| refresh_consume | ✅  | ✅   | Consume (mark as read) a pending context refresh |

### Server Management (CLI only)

| Operation       | CLI | HTTP | Notes |
|-----------------|-----|------|-------|
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
