# Buffer & STDIN Conventions

This guide covers how to handle large content across CLI and HTTP surfaces.

## CLI Content Sources

### From Buffer File
```bash
# Write to buffer
echo "Large content here" > .holocron/sync/tmp/buffer

# Use with any command
holo ops put_file --from-buffer --path docs/large.md
holo progress --from-buffer
holo context-refresh --from-buffer
```

### From STDIN
```bash
# Pipe content
cat large-file.txt | holo ops put_file --stdin --path docs/large.md

# Use with ops
echo '{"query":"test"}' | holo ops search --stdin
```

## HTTP Content Sources

### JSON Body
```bash
curl -X PUT -H "Content-Type: application/json" \
  -d '{"path":"docs/large.md","content":"Large content here"}' \
  "http://localhost:4567/v1/{holo}/ops/put_file"
```

### Base64 Encoding
```bash
# For binary content
content=$(base64 -i binary-file.png)
curl -X PUT -H "Content-Type: application/json" \
  -d "{\"path\":\"image.png\",\"content\":\"$content\",\"encoding\":\"base64\"}" \
  "http://localhost:4567/v1/{holo}/ops/put_file"
```

## Best Practices

- Use `--from-buffer` for complex markdown content
- Use `--stdin` for pipeline workflows
- HTTP JSON bodies for programmatic access
- Base64 encoding for binary content via HTTP
- Avoid CLI argument length limits with large content
