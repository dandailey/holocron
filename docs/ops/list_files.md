# list_files — Enumerate files with filters

- Method: GET or POST
- Path: `/v1/{holo}/ops/list_files`

## Params / Body
- `dir` (string, default `.`)
- `include_glob[]` (repeatable)
- `exclude_glob[]` (repeatable)
- `extensions[]` (repeatable)
- `max_depth` (int)
- `sort` (`path|mtime|size`, default `path`)
- `order` (`asc|desc`, default `asc`)
- `limit`, `offset` (ints)

## Examples
```bash
# CLI
holo ops list_files --include-glob "**/*.md" --limit 5

# HTTP
curl -s "http://localhost:4567/v1/{holo}/ops/list_files?include_glob=**/*.md&limit=5"
```

## Response
```json
{ "files": [{"path":"README.md","size":123,"mtime":"2025-09-28T00:00:00-0700","ext":"md"}],
  "total": 42 }
```
