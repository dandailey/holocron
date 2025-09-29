# Holocron

> **Persistent memory framework for AI assistants working on long-form projects**

Holocron solves the fundamental problem of AI assistants having no memory between chat sessions. Instead of starting from scratch every time, you can maintain context, track decisions, and pick up exactly where you left off.

## Quick Start

```bash
# Install the gem
gem install holocron

# Initialize a new project (name + directory)
holo init my-awesome-project ./my-awesome-project

# Registering is automatic; select it to work from anywhere
holo list
holo select my-awesome-project

# Validate your setup (now uses selected holo if not in directory)
holo doctor

# Get help
holo help                    # Show all commands
holo help init               # Show help for specific command
```

You can also register an existing holo or forget one:

```bash
holo register archived ./archived-holo
holo forget archived
```

## What is Holocron?

Holocron is like the VHS tape from "50 First Dates" - every session, you read it to remember what the hell you were doing. It's a structured documentation system that acts as persistent memory for AI assistants, enabling:

- **Context maintenance** across chat sessions
- **Decision tracking** with reasoning and dates
- **Progress logging** with detailed task histories
- **Environment documentation** for reproducible setups
- **Longform documentation** management
- **Context refreshes** for handoffs between sessions

## Key Features

- 🚀 **One-command setup**: `holo init` creates a complete Holocron structure
- 🔍 **Validation**: `holo doctor` ensures your Holocron is healthy
- 📝 **Context management**: Create refresh files for session handoffs
- 📚 **Documentation tools**: Concatenate longform docs automatically
- 💡 **Suggestion system**: Contribute improvements back to the framework
- 🤝 **Contributor support**: `holo contribute` initializes project-specific working memory
- 🔧 **Self-contained**: No external dependencies, works offline

## Documentation

See [docs/index.md](docs/index.md) for the complete documentation hub.

## Basic Usage

### Initialize and Select a Project
```bash
holo init my-project ./my-project
# Creates complete Holocron structure and registers it by name

holo select my-project
# Selects the holo so other commands can run from anywhere
```

### Validate Structure
```bash
holo doctor
# Checks the currently selected holo for common issues and validates structure
```

### Create Context Refresh
```bash
holo context-refresh --name "milestone_reached"
# Creates a context refresh file for session handoffs
```

### Manage Documentation
```bash
holo longform concat docs/
# Concatenates numbered documentation files
```

### Contribute Suggestions
```bash
holo suggest "Add support for custom templates"
# Records suggestions for framework improvements
```

### Initialize Contributor Working Memory
```bash
holo contribute
# Creates project-specific working memory for contributors
```

### Manage Buffer for Longform Content
```bash
holo buffer                    # Show buffer content (default action)
holo buffer clear             # Clear the buffer
holo buffer status            # Show buffer file status
holo progress --from-buffer --summary "Summary" --name "entry_name"  # Use buffer content for progress entry
holo context-refresh --name "reason"     # Create context refresh with custom name
holo suggest --from-buffer               # Use buffer content for suggestion
```

## Development

```bash
# Clone and setup
git clone https://github.com/dandailey/holocron.git
cd holocron
bundle install

# Run tests
bundle exec rspec

# Build gem
gem build holocron.gemspec
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](docs/contributing.md) for details.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Ready to give your AI assistant a memory?** [Get started with the installation guide](docs/installation.md) →
