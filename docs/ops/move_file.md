# move_file — Move/rename file

- Method: POST
- Path: `/v1/{holo}/ops/move_file`

## Body
- `from` (required)
- `to` (required)
- `if_match_sha256` (optional, precondition)
- `overwrite` (bool, default false)

## Examples
```bash
# CLI
holo ops move_file --from old.md --to new.md

# HTTP
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"from":"old.md","to":"new.md"}' \
  "http://localhost:4567/v1/{holo}/ops/move_file"
```

## Response
```json
{ "from": "old.md", "to": "new.md", "moved": true, "sha256": "abc123..." }
```
