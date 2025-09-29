# delete_file — Delete file

- Method: DELETE
- Path: `/v1/{holo}/ops/delete_file`

## Body
- `path` (required)
- `if_match_sha256` (optional, precondition)

## Examples
```bash
# CLI
holo ops delete_file --path docs/demo.md

# HTTP
curl -s -X DELETE -H "Content-Type: application/json" \
  -d '{"path":"docs/demo.md"}' \
  "http://localhost:4567/v1/{holo}/ops/delete_file"
```

## Response
```json
{ "path": "docs/demo.md", "deleted": true }
```
