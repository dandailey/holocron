# Commands Reference

Complete documentation for all Holocron CLI commands.

## Overview

Holocron provides a simple CLI with the following commands:

- `holo init` - Initialize a new Holocron
- `holo list` - List registered holocrons
- `holo select <name>` - Select an active holocron to run commands against
- `holo register <name> <directory>` - Register an existing holocron
- `holo forget <name>` - Remove a holocron from the registry
- `holo doctor` - Validate Holocron structure
- `holo version` - Show version information
- `holo context-refresh` - Create context refresh files
- `holo progress` - Add progress log entries
- `holo onboard` - Display framework guide and process context refreshes
- `holo framework` - Display framework documentation
- `holo guide` - Display specific guides
- `holo status` - Show holocron information
- `holo longform concat` - Concatenate documentation
- `holo suggest` - Submit framework suggestions
- `holo contribute` - Initialize working memory for contributing to this project
- `holo buffer` - Manage buffer file for longform content

## Global Options

All commands support these global options:

- `--help` - Show help information
- `--version` - Show version (same as `holo version`)

## Commands

### `holo init NAME DIRECTORY`

Initialize a new Holocron with the given name in the specified directory, and register it for global access.

**Usage:**
```bash
holo init <name> <directory>
```

**Options:**
- `--into DIRECTORY` - Directory to create the Holocron in (default: "holocron")

**Examples:**
```bash
# Create Holocron in specific directory with name
holo init my-project ./my-project

# Create Holocron in custom location
holo init docs-holo ./docs/holocron
```

**What it creates:**
- Complete directory structure (`progress_logs/`, `context_refresh/`, `knowledge_base/`, `longform_docs/`, `files/`)
- All required files (`README.md`, `action_plan.md`, etc.)
- Registers the holocron under the given name in `~/.holocron.yml`

### `holo doctor [DIRECTORY]`

Validate Holocron structure and report issues.

**Usage:**
```bash
holo doctor [DIRECTORY]
```

**Options:**
- `--fix` - Attempt to fix common issues automatically

**Examples:**
```bash
# Check currently selected holo
holo doctor

# Check specific directory (overrides selection)
holo doctor /path/to/holocron

# Try to fix issues
holo doctor --fix my-project
```

**What it checks:**
- Required directories exist
- Required files exist
- Configuration file is valid
- Directory structure is correct
- File permissions are appropriate

### `holo version`

Show Holocron version information.

**Usage:**
```bash
holo version
```

**Output:**
```
Holocron 0.1.0
```

### `holo context-refresh`

Create a new context refresh file for session handoffs.

**Usage:**
```bash
holo context-refresh
```

**Options:**
- `--name NAME` - Custom name for the entry (default: context_refresh)

**Examples:**
```bash
# Basic usage
holo context-refresh

# With custom name
holo context-refresh --name "feature_complete"
```

**What it creates:**
- Context refresh file in `context_refresh/`
- Timestamped filename (YYYY_MM_DD_HHMMSS format)
- Template with sections for objectives, decisions, files, blockers
- Ready for immediate use (no manual editing required)

### `holo progress [CONTENT]`

Add a progress log entry to document work completed.

**Usage:**
```bash
holo progress [CONTENT]
```

**Options:**
- `--summary SUMMARY` - Brief summary (auto-generated if not provided)
- `--name NAME` - Custom name for the entry (default: progress_update)
- `--from-buffer` - Read content from buffer file instead of CONTENT argument

**Examples:**
```bash
# Basic usage with content
holo progress "Added user authentication system with JWT tokens and role-based access control"

# With custom summary and name
holo progress "Detailed implementation notes..." --summary "Added user auth" --name "user_auth"

# Using buffer file for longform content
holo progress --from-buffer --summary "Major refactoring" --name "refactor"

# Minimal usage (just buffer)
holo progress --from-buffer
```

**What it creates:**
- Detailed log file in `progress_logs/`
- Updates main `progress_log.md` with summary
- Timestamped filename (YYYY_MM_DD_HHMMSS format)

### `holo onboard`

Display the framework guide and process any pending context refreshes.

**Usage:**
```bash
holo onboard
```

**What it does:**
- Displays the complete Holocron framework guide
- Automatically processes any pending context refreshes
- Renames `_PENDING_` files to mark them as executed
- Shows content of processed refreshes

**⚠️ WARNING:** Only run once per session! This command consumes ALL pending context refreshes.

### `holo framework`

Display the Holocron framework guide.

**Usage:**
```bash
holo framework
```

**What it does:**
- Shows the complete framework documentation
- Same content as `holo onboard` but without context refresh processing

### `holo guide [GUIDE_NAME]`

Display a specific Holocron guide.

**Usage:**
```bash
holo guide [GUIDE_NAME]
```

**Available guides:**
- `refreshing-context` - How to create context refreshes
- `progress-logging` - How to log progress
- `offboarding` - How to offboard from a session
- `creating-long-form-docs` - How to create long documents

**Examples:**
```bash
# Show all available guides
holo guide

# Show specific guide
holo guide progress-logging
```

### `holo status [DIRECTORY]`

Show holocron information and status.

**Usage:**
```bash
holo status [DIRECTORY]
```

**What it shows:**
- Holocron location and detection status
- Framework information
- Directory structure validation

**Examples:**
```bash
# Check selected holo
holo status

# Check specific directory
holo status my-project
```

### `holo longform concat DIRECTORY`

Concatenate numbered documentation files into a single document.

**Usage:**
```bash
holo longform concat DIRECTORY
```

**Options:**
- `--output FILE` - Output file path (default: directory name + .md)

**Examples:**
```bash
# Concatenate files in docs/
holo longform concat docs/

# Concatenate with custom output
holo longform concat docs/ --output complete-guide.md
```

**What it does:**
- Finds all files matching `###_*.md` pattern
- Sorts them numerically
- Concatenates content in order
- Creates single output file

**File naming convention:**
- `000_intro.md` - Introduction (only file with H1 heading)
- `010_section.md` - First section (starts with ##)
- `020_another.md` - Second section
- etc.

### `holo suggest [MESSAGE]`

Create a suggestion for the base Holocron framework.

**Usage:**
```bash
holo suggest [MESSAGE]
```

**Options:**
- `--open-issue` - Open a GitHub issue (not yet implemented)
- `--from-buffer` - Read content from buffer file instead of MESSAGE

**Examples:**
```bash
# Create suggestion
holo suggest "Add support for custom templates"

# Create suggestion with option
holo suggest "Add support for custom templates" --open-issue

# Using buffer file for longform content
holo suggest --from-buffer
```

**What it creates:**
- Suggestion file in `_memory/suggestion_queue/`
- Timestamped filename
- Template with description, rationale, implementation notes
- Ready for review and potential contribution

### `holo contribute`

Initialize a working Holocron for contributing to this project.

**Usage:**
```bash
holo contribute
```

**Requirements:**
- Must be run from a Holocron project directory
- Requires `holocron.gemspec` and `lib/holocron.rb` to be present

**Examples:**
```bash
# From the Holocron project root
holo contribute

# From wrong directory (will show error)
cd /tmp
holo contribute
# ❌ This command must be run from a Holocron project directory
```

**What it creates:**
- Complete `.holocron/` directory structure
- Project-specific README with contributor context
- Development-focused action plan and project overview
- Standard Holocron memory structure
- All files are ignored by git to prevent conflicts

**Safety features:**
- Checks for Holocron project files before proceeding
- Warns before overwriting existing `.holocron/` directory
- Provides clear error messages for wrong usage

## Command Examples

### Complete Workflow

```bash
# Initialize a new project and select it
holo init my-awesome-project ./my-awesome-project
holo select my-awesome-project

# Validate setup from anywhere
holo doctor

# Create context refresh
holo context-refresh --name "starting_development"

# Work on project...
# (edit files, make progress)

# Create another context refresh
holo context-refresh --name "ready_for_testing"

# Validate before committing
holo doctor
```

### Documentation Workflow

```bash
# Create longform documentation
mkdir docs
echo "# Introduction" > docs/000_intro.md
echo "## Getting Started" > docs/010_getting_started.md
echo "## Advanced Usage" > docs/020_advanced_usage.md

# Concatenate into single document
holo longform concat docs/ --output complete-guide.md
```

### Suggestion Workflow

```bash
# Submit a suggestion
holo suggest "Add support for custom templates"

# Check what was created
ls _memory/suggestion_queue/
cat _memory/suggestion_queue/*.md
```

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `10` - Validation failed (doctor command)

## Environment Variables

- `HOLOCRON_CONFIG` - Path to custom configuration file (not yet implemented)
- `HOLOCRON_VERBOSE` - Enable verbose output (not yet implemented)

## Configuration

Holocron detects holocrons by the presence of a `_memory/` directory:

No configuration file is required. Holocrons are automatically detected by the presence of a `_memory/` directory.

### `holo buffer [ACTION]`

Manage buffer file for longform content. The buffer system allows AI agents to write complex markdown content to a file and use it with other commands, avoiding CLI argument length limits and escaping issues.

**Usage:**
```bash
holo buffer [ACTION]
```

**Actions:**
- `show` (default) - Display buffer content
- `clear` - Clear the buffer file
- `status` - Show buffer file information

**Examples:**
```bash
# Show buffer content (default action)
holo buffer

# Clear the buffer
holo buffer clear

# Show buffer status
holo buffer status
```

**Buffer File Location:**
- `_memory/tmp/buffer` - The buffer file location

**Integration with Other Commands:**
The `--from-buffer` flag can be used with:
- `holo progress --from-buffer`
- `holo suggest --from-buffer`

**Workflow (for AI agents):**
1. Write content to `_memory/tmp/buffer` using file writing tools/functions
2. Use `holo buffer` to verify content
3. Run commands with `--from-buffer` flag
4. Use `holo buffer clear` when done

## Troubleshooting Commands

### Command not found
```bash
# Check if gem is installed
gem list holocron

# Check PATH
echo $PATH | grep -o '[^:]*gem[^:]*'

# Use with bundler
bundle exec holo version
```

### Permission errors
```bash
# Check file permissions
ls -la _memory/

# Fix permissions
chmod -R 755 _memory/
```

### Validation failures
```bash
# Run doctor with verbose output
holo doctor --fix

# Check specific files
ls -la _memory/
ls -la _memory/
```

## Next Steps

- **[Read the Roadmap](roadmap.md)** - See what's coming next
- **[Check Architecture](architecture.md)** - Understand the technical design
- **[Contribute](contributing.md)** - Help improve Holocron
