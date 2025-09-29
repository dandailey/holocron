# search — Search files with context

- Method: POST
- Path: `/v1/{holo}/ops/search`

## Body
- `query` (required)
- `regex` (bool, default false)
- `case` (`sensitive|insensitive`, default `insensitive`)
- `before`, `after` (int, context lines)
- Plus shared list filters

## Examples
```bash
# CLI
holo ops search --pattern "memory" --before 2 --after 2

# HTTP
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"query":"memory","before":2,"after":2}' \
  "http://localhost:4567/v1/{holo}/ops/search"
```

## Response
```json
{ "query": "memory", "total_files": 1, "total_matches": 3,
  "results": [{"path": "README.md", "matches": [...]}] }
```
