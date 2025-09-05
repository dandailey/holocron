# Commands Reference

Complete documentation for all Holocron CLI commands.

## Overview

Holocron provides a simple CLI with the following commands:

- `holo init` - Initialize a new Holocron
- `holo doctor` - Validate Holocron structure
- `holo version` - Show version information
- `holo context-new` - Create context refresh files
- `holo longform concat` - Concatenate documentation
- `holo suggest` - Submit framework suggestions
- `holo contribute` - Initialize working memory for contributing to this project

## Global Options

All commands support these global options:

- `--help` - Show help information
- `--version` - Show version (same as `holo version`)

## Commands

### `holo init [DIRECTORY]`

Initialize a new Holocron in the specified directory.

**Usage:**
```bash
holo init [DIRECTORY]
```

**Options:**
- `--into DIRECTORY` - Directory to create the Holocron in (default: "holocron")

**Examples:**
```bash
# Create Holocron in current directory
holo init

# Create Holocron in specific directory
holo init my-project

# Create Holocron in custom location
holo init --into docs/holocron
```

**What it creates:**
- Complete directory structure (`_memory/`, `longform_docs/`, `files/`)
- All required files (`README.md`, `action_plan.md`, etc.)
- Configuration file (`.holocron.yml`)
- Placeholder content for immediate use

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
# Check current directory
holo doctor

# Check specific directory
holo doctor my-project

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

### `holo context-new [REASON]`

Create a new context refresh file for session handoffs.

**Usage:**
```bash
holo context-new [REASON]
```

**Options:**
- `--why REASON` - Reason for context refresh

**Examples:**
```bash
# Create with reason
holo context-new "Reached milestone, need to hand off to future-me"

# Create with option
holo context-new --why "Weekend break, picking up Monday"

# Create without reason (will prompt)
holo context-new
```

**What it creates:**
- Context refresh file in `_memory/context_refresh/`
- Timestamped filename with `_PENDING_` prefix
- Template with sections for objectives, decisions, files, blockers
- Instructions for completing and finalizing

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

**Examples:**
```bash
# Create suggestion
holo suggest "Add support for custom templates"

# Create suggestion with option
holo suggest "Add support for custom templates" --open-issue
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
# Initialize a new project
holo init my-awesome-project
cd my-awesome-project

# Validate setup
holo doctor

# Create context refresh
holo context-new "Starting development phase"

# Work on project...
# (edit files, make progress)

# Create another context refresh
holo context-new "Ready for testing phase"

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

Holocron uses a `.holocron.yml` configuration file:

```yaml
base_repo: "https://github.com/dandailey/holocron"
base_version: "0.1.0"
obsidian_vault: null
local_base_path: null
```

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
cat .holocron.yml
```

## Next Steps

- **[Read the Roadmap](roadmap.md)** - See what's coming next
- **[Check Architecture](architecture.md)** - Understand the technical design
- **[Contribute](contributing.md)** - Help improve Holocron
