# Holocron Registry Guide

The registry lets you manage multiple holocrons system-wide and run commands from any directory.

## TL;DR

- `holo list` — Show registered holocrons, marking active/default
- `holo select <name>` — Make a holocron active for commands
- `holo init <name> <dir>` — Create a holocron and register it
- `holo register <name> <dir>` — Register an existing holocron
- `holo forget <name>` — Remove a holocron from the registry

Active selection is used whenever auto-discovery doesn’t find a holocron in the current path.

## Concepts

- **Registry file**: `~/.holocron.yml`
- **default**: First registered holo, used as the implied default
- **active**: The currently selected holo; commands act on this when not in a holocron dir and `--dir` is not provided

## Workflows

### Create and work from anywhere
```bash
holo init docs ./docs
holo select docs
holo doctor
```

### Register an existing holocron
```bash
holo register research ~/work/research-holo
holo select research
holo status
```

### Forget a holocron
```bash
holo forget research
holo list
```

## Overrides

- Use `--dir /path/to/holo` to act on a specific holocron directory, overriding selection.
- Auto-discovery still works when you’re inside a holocron; selection is the fallback.

## Notes

- A valid holocron directory contains `_memory/`.
- Moving a registered holocron requires re-registering with the new path.

