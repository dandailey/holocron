# put_file — Create/update file

- Method: PUT
- Path: `/v1/{holo}/ops/put_file`

## Body
- `path` (required)
- `content` (required)
- `encoding` (`plain|base64`, default `plain`)
- `if_match_sha256` (optional, precondition)
- `author`, `message` (optional)

## Examples
```bash
# CLI
holo ops put_file --path docs/demo.md --content "Hello world"

# HTTP
curl -s -X PUT -H "Content-Type: application/json" \
  -d '{"path":"docs/demo.md","content":"Hello world"}' \
  "http://localhost:4567/v1/{holo}/ops/put_file"
```

## Response
```json
{ "path": "docs/demo.md", "sha256": "abc123...", "bytes_written": 11, "created": true }
```
