# apply_diff — Apply git-style unified diff

- Method: POST
- Path: `/v1/{holo}/ops/apply_diff`

## Body
- `diff` (required, unified diff content)
- `author`, `message` (optional)

## Examples
```bash
# CLI
holo ops apply_diff --diff "$(cat changes.diff)"

# HTTP
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"diff":"--- a/README.md\n+++ b/README.md\n@@ -1 +1,2 @@\n # Hello\n+World"}' \
  "http://localhost:4567/v1/{holo}/ops/apply_diff"
```

## Response
```json
{ "applied": true, "summary": {"total_files": 1, "created": 0, "modified": 1, "deleted": 0, "hunks_applied": 1, "errors": 0},
  "results": [...] }
```
