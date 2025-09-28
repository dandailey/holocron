# Upgrade Guide: Holocron 0.1 → 0.2

This guide is for AI assistants performing the upgrade. Read fully before acting.

## Objective
Promote `_memory/` contents to the holocron root, introduce `HOLOCRON.json` with `version: 0.2.0`, and validate.

## Mapping Rules
- Known moves:
  - `_memory/decision_log.md` → `decision_log.md`
  - `_memory/env_setup.md` → `env_setup.md`
  - `_memory/test_list.md` → `test_list.md`
  - `_memory/progress_logs/` → `progress_logs/`
  - `_memory/context_refresh/` → `context_refresh/`
  - `_memory/knowledge_base/` → `knowledge_base/`
  - `_memory/notebooks/` → `notebooks/`
  - `_memory/tmp/` → `tmp/` (keep `tmp/buffer`)
  - `_memory/suggestion_queue/` → `archive/suggestions/` (deprecated)
- Unknown `_memory/*` entries: move into `files/` preserving structure.
- Conflicts: prefer existing destination; move source into `archive/migration_conflicts/<timestamp>/…`.

## Plan (AI)
1. Create a timestamped backup dir (e.g., `upgrade_backups/YYYY_MM_DD_HHMMSS/`) and copy `_memory/` into it
2. Apply the mapping rules above to move files/dirs
3. Create or update `HOLOCRON.json` with `{ "version": "0.2.0" }`
4. Remove empty `_memory/` if present
5. Write a ledger to `upgrade_logs/YYYY_MM_DD_HHMMSS_upgrade_0_1_to_0_2.md` listing moves, conflicts, and results

## Validation
- Write a small progress entry (CLI or HTTP) and confirm it appears in `progress_logs/`
- Read `progress_log.md` via HTTP `read_file` op
- Confirm `HOLOCRON.json` exists with `version: 0.2.0`

## Rollback Notes
- Use the backup dir to restore prior state if necessary
- Keep the ledger for audit

Proceed carefully; avoid assumptions. Follow the rules exactly and validate each step.
