# Holocron

> **Persistent memory framework for AI assistants working on long-form projects**

Holocron solves the fundamental problem of AI assistants having no memory between chat sessions. Instead of starting from scratch every time, you can maintain context, track decisions, and pick up exactly where you left off.

## Quick Start

```bash
# Install the gem
gem install holocron

# Initialize a new project
holo init my-awesome-project

# Validate your setup
holo doctor my-awesome-project
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

- **[Framework Guide](docs/framework/README.md)** - Complete Holocron framework documentation
- **[Installation Guide](docs/installation.md)** - Detailed setup instructions
- **[Commands Reference](docs/commands.md)** - Complete command documentation
- **[Roadmap](docs/roadmap.md)** - Future features and development plans
- **[Contributing](docs/contributing.md)** - How to contribute to the project

### Guides

- **[Refreshing Context](docs/guides/refreshing-context.md)** - How to create context refresh files
- **[Creating Long Form Docs](docs/guides/creating-long-form-docs.md)** - Managing complex documentation

## Basic Usage

### Initialize a Project
```bash
holo init my-project
# Creates complete Holocron structure with all necessary files
```

### Validate Structure
```bash
holo doctor my-project
# Checks for common issues and validates structure
```

### Create Context Refresh
```bash
holo context-new "Reached milestone, need to hand off to future-me"
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
