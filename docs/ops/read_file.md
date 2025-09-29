# read_file — Read file content

- Method: GET
- Path: `/v1/{holo}/ops/read_file`

## Params
- `path` (required)
- `offset` (int, lines)
- `limit` (int, lines)

## Examples
```bash
# CLI
holo ops read_file --path README.md

# HTTP
curl -s "http://localhost:4567/v1/{holo}/ops/read_file?path=README.md"
```

## Response
```json
{ "path": "README.md", "size": 123, "mtime": "2025-09-28T00:00:00-0700", 
  "content": "# Hello", "sha256": "abc123..." }
```
