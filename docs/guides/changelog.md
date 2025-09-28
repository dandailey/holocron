# Holocron Changelog

## Version 0.2.0 - Layout Modernization

### Major Changes

**New 0.2 Layout System**
- Introduced `HOLOCRON.json` metadata file for version detection
- Moved all `_memory/` contents to holocron root for cleaner structure
- Implemented `PathResolver` class for automatic layout detection and path mapping
- Maintains full backwards compatibility with 0.1 layouts

**Path Resolution Overhaul**
- All commands now use `PathResolver` for consistent path handling
- Automatic detection of 0.1 vs 0.2 layouts
- Commands work seamlessly with both layout versions
- No more hardcoded `_memory/` path assumptions

**Improved Error Handling**
- Better guidance when no holocron is selected
- Clearer error messages distinguishing between layout versions
- Helpful fallback suggestions for common issues

### File Structure Changes

**0.2 Layout (New Default)**
```
holocron/
├── HOLOCRON.json          # Version metadata
├── progress_log.md        # Main progress summary
├── decision_log.md        # Decision tracking
├── env_setup.md          # Environment setup
├── test_list.md          # Test tracking
├── progress_logs/        # Detailed progress entries
├── context_refresh/      # Context refresh files
├── knowledge_base/       # Knowledge management
├── notebooks/            # Research notebooks
├── tmp/                  # Temporary files (including buffer)
├── files/                # Custom content
├── longform_docs/        # Complex documentation
└── archive/              # Archived content
```

**0.1 Layout (Legacy Support)**
```
holocron/
├── _memory/              # All memory content
│   ├── progress_logs/
│   ├── context_refresh/
│   ├── knowledge_base/
│   ├── notebooks/
│   ├── tmp/
│   └── ...
└── files/                # Custom content
```

### Technical Improvements

**Detection Logic**
- `HOLOCRON.json` with `version: "0.2.0"` → 0.2 layout
- `_memory/` directory presence → 0.1 layout
- Graceful fallback for invalid or missing metadata

**Command Updates**
- `holo init` now creates 0.2 layout by default
- All path-sensitive commands use `PathResolver`
- Progress logging works correctly in both layouts
- Buffer system updated for new path structure

**Registry & Discovery**
- Registry validation updated for both layout types
- Auto-discovery works with both 0.1 and 0.2 holocrons
- Improved error messages for invalid directories

### Migration

**For Existing Holocrons**
- Use `holo upgrade` command for step-by-step migration
- See [upgrade_0_1_to_0_2.md](upgrade_0_1_to_0_2.md) for detailed instructions
- Migration preserves all data and creates backup
- No data loss during upgrade process

**For New Holocrons**
- `holo init` creates 0.2 layout by default
- All new features assume 0.2 layout
- 0.1 layout remains fully supported for existing holocrons

### Breaking Changes

**None** - This release maintains full backwards compatibility. Existing 0.1 holocrons continue to work without modification.

### Deprecated Features

- `suggestion_queue/` directory (moved to `archive/suggestions/`)
- Direct `_memory/` path references in documentation
- Hardcoded path assumptions in custom scripts

### What's Next

- Enhanced ops API with full CLI/HTTP parity
- Rack server adapter for better hosting options
- Performance improvements for large holocrons
- Additional path resolution features

---

## Version 0.1.0 - Initial Release

### Core Features
- Atomic holocron architecture
- CLI command suite
- Buffer system for longform content
- Ops API with HTTP server
- Registry management
- Context refresh system
- Progress logging
- Research notebooks
- Template management
