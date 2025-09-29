# Server Management Guide

This guide covers how to manage the Holocron web server, including starting, stopping, monitoring, and troubleshooting.

## Overview

The Holocron web server provides HTTP access to your Holocrons via a REST API. It supports both foreground and background operation modes.

## Server Commands

### Starting the Server

**Foreground Mode (Default):**
```bash
holo server start
```

**Background Mode:**
```bash
holo server start --background
```

**Custom Port/Host:**
```bash
holo server start --port 3000 --host 0.0.0.0
holo server start --background --port 8080
```

### Selecting the HTTP adapter

The server now runs as a Rack app. By default it uses WEBrick. You can choose Puma if available:

```bash
# Use Puma (if installed)
holo server start --adapter puma

# Explicitly use WEBrick
holo server start --adapter webrick
```

If Puma is not available, the server falls back to WEBrick automatically.

### Stopping the Server

```bash
holo server stop
```

This gracefully stops the server if it's running in background mode. For foreground mode, use Ctrl+C.

### Checking Server Status

```bash
holo server status
```

This provides detailed information about the server including:
- Running status and PID
- Server URL and uptime
- Connectivity test
- Registered Holocrons
- Log file location

### Restarting the Server

```bash
holo server restart
```

This stops the current server (if running) and starts a new one with the same configuration.

## Server Modes

### Foreground Mode
- Server runs in the current terminal
- Output is displayed directly
- Use Ctrl+C to stop
- Good for development and debugging

### Background Mode
- Server runs as a background process
- Output is redirected to log file
- Managed via `holo server stop/start/status`
- Good for production use

## Configuration

### Default Settings
- **Host**: localhost
- **Port**: 4567
- **PID File**: ~/.holocron_server.pid
- **Log File**: ~/.holocron_server.log
 - **Adapter**: webrick (puma optional)

### Custom Configuration
All settings can be overridden with command-line options:

```bash
holo server start --host 0.0.0.0 --port 8080 --background
```

## API Endpoints

Once running, the server provides these endpoints:

### Registry Endpoints
- `GET /v1/holocrons` - List all registered Holocrons
- `GET /v1/help` - Show API documentation

### Holocron-Specific Endpoints
- `GET /v1/{holo-name}/status` - Get Holocron status
- `GET /v1/{holo-name}/help` - Show Holocron-specific API docs

### Operations API
All operations are under `/v1/{holo-name}/ops/`:

- `GET/POST /v1/{holo-name}/ops/list_files` - List files with filters
- `GET /v1/{holo-name}/ops/read_file` - Read file content
- `PUT /v1/{holo-name}/ops/put_file` - Create/update file
- `DELETE /v1/{holo-name}/ops/delete_file` - Delete file
- `POST /v1/{holo-name}/ops/search` - Search files
- `POST /v1/{holo-name}/ops/move_file` - Move/rename file
- `POST /v1/{holo-name}/ops/bundle` - Bundle multiple files
- `POST /v1/{holo-name}/ops/apply_diff` - Apply git-style diff

## Troubleshooting

### Server Won't Start

**Port Already in Use:**
```bash
# Check what's using the port
lsof -i :4567

# Use a different port
holo server start --port 3000
```

**Permission Issues:**
- Ensure you have write access to your home directory (for PID and log files)
- Check if another user is running a server on the same port

### Server Not Responding

**Check Status:**
```bash
holo server status
```

**Check Logs:**
```bash
tail -f ~/.holocron_server.log
```

**Restart Server:**
```bash
holo server restart
```

### Stale PID File

If you see "Stale PID file found" in status:

```bash
# Remove the stale PID file
rm ~/.holocron_server.pid

# Start the server
holo server start --background
```

### Background Server Issues

**Server Started but Not Responding:**
1. Check logs: `tail -f ~/.holocron_server.log`
2. Verify PID is correct: `ps aux | grep holo`
3. Try restarting: `holo server restart`

**Can't Stop Background Server:**
```bash
# Force kill if graceful stop fails
holo server stop

# If that doesn't work, find and kill manually
ps aux | grep holo
kill -9 <PID>
rm ~/.holocron_server.pid
```

## Development vs Production

### Development
- Use foreground mode for immediate feedback
- Monitor logs directly in terminal
- Easy to stop with Ctrl+C

### Production
- Use background mode for persistence
- Monitor via `holo server status`
- Set up log rotation for log files
- Consider using a process manager like systemd

## Security Considerations

### Local Development
- Default localhost binding is safe
- No authentication required
- Suitable for local AI agent workflows

### Network Exposure
- Use `--host 0.0.0.0` only if needed
- Consider firewall rules
- No built-in authentication (add if exposing publicly)

## Integration with AI Agents

The server is designed for AI agent workflows:

1. **Start server in background**: `holo server start --background`
2. **AI agent makes HTTP requests** to the API endpoints
3. **Monitor via status**: `holo server status`
4. **Stop when done**: `holo server stop`

The `apply_diff` endpoint is particularly useful for AI agents as it allows batch file operations with a single HTTP request.

## Examples

### Basic Workflow
```bash
# Start server
holo server start --background

# Check it's running
holo server status

# Use the API (in another terminal)
curl http://localhost:4567/v1/holocron/ops/list_files

# Stop when done
holo server stop
```

### Development Workflow
```bash
# Start in foreground for development
holo server start --port 3000

# In another terminal, test endpoints
curl http://localhost:3000/v1/help

# Stop with Ctrl+C
```

### Production Setup
```bash
# Start with custom configuration
holo server start --host 0.0.0.0 --port 8080 --background

# Monitor status
holo server status

# Check logs
tail -f ~/.holocron_server.log
```