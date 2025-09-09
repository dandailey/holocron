# Architecture

This document describes the technical architecture and design decisions behind Holocron.

## Overview

Holocron is designed as a self-contained Ruby gem that provides a CLI tool for managing persistent memory frameworks. The architecture emphasizes simplicity, portability, and extensibility.

## Core Principles

### 1. Self-Contained
- No external dependencies beyond Ruby standard library and common gems
- Templates embedded in the gem for offline operation
- No network requirements for basic functionality

### 2. Portable
- Works across different operating systems
- No symlink dependencies for core functionality
- Consistent behavior across environments

### 3. Extensible
- Modular command structure
- Plugin architecture planned for future versions
- Easy to add new commands and features

### 4. User-Friendly
- Simple CLI interface
- Clear error messages
- Comprehensive documentation

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Input    │───▶│   CLI Layer     │───▶│  Command Layer  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │  Holocron       │    │  Template Mgmt  │
                       │  Detection      │    └─────────────────┘
                       └─────────────────┘             │
                                │                      ▼
                                ▼            ┌─────────────────┐
                       ┌─────────────────┐    │   File System   │
                       │   Validation    │    │   Operations    │
                       └─────────────────┘    └─────────────────┘
```

## Component Overview

### CLI Layer (`lib/holocron/cli.rb`)

The main entry point using the Thor gem for command-line interface:

- **Command routing** - Routes commands to appropriate handlers
- **Option parsing** - Handles command-line options and arguments
- **Error handling** - Provides consistent error handling across commands
- **Help system** - Generates help text and usage information

### Command Layer (`lib/holocron/commands/`)

Individual command implementations:

- **Init** - Creates new Holocron structures
- **Doctor** - Validates existing Holocrons
- **Version** - Shows version information
- **Context** - Manages context refresh files
- **Progress** - Manages progress log entries
- **Onboard** - Displays framework guide and processes context refreshes
- **Framework** - Displays framework documentation
- **Guide** - Displays specific guides
- **Status** - Shows holocron information
- **Longform** - Handles documentation concatenation
- **Suggest** - Manages framework suggestions
- **Contribute** - Initializes contributor working memory

### Template Management (`lib/holocron/template_manager.rb`)

Handles the creation and management of Holocron templates:

- **Template copying** - Copies embedded templates to target directories
- **File generation** - Creates placeholder files with proper content
- **Directory structure** - Ensures correct directory hierarchy
- **File generation** - Creates all necessary files and directories

### Holocron Detection

Holocrons are detected by the presence of a `_memory/` directory:

- **No configuration files required** - Simple directory-based detection
- **Atomic design** - Each holocron is completely self-contained
- **Portable** - Can be moved between environments without dependencies

## File Structure

### Gem Structure
```
holocron/
├── exe/
│   └── holo                 # CLI executable
├── lib/
│   └── holocron/
│       ├── cli.rb           # Main CLI class
│       ├── commands/        # Command implementations
│       ├── template_manager.rb
│       └── version.rb
├── spec/                    # Test suite
├── docs/                    # Documentation
├── holocron.gemspec        # Gem specification
└── README.md
```

### Generated Holocron Structure
```
project/
├── README.md               # Main documentation
├── action_plan.md          # Project plan
├── project_overview.md     # High-level overview
├── progress_log.md         # Progress summary
├── todo.md                 # Overflow tasks
├── _memory/                # Detailed memory
│   ├── decision_log.md     # Architectural decisions
│   ├── env_setup.md        # Environment details
│   ├── test_list.md        # Test tracking
│   ├── progress_logs/      # Detailed logs
│   ├── context_refresh/    # Session handoffs
│   └── knowledge_base/     # Freeform knowledge
├── longform_docs/          # Complex documentation
└── files/                  # File workspace
```

## Design Decisions

### CLI Framework: Thor

**Decision**: Use Thor for CLI framework
**Rationale**: 
- Simple and reliable
- Good balance of features vs complexity
- Well-maintained and stable
- Easy to extend with new commands

**Alternatives considered**: Commander, GLI, OptionParser
**Trade-offs**: Less features than some alternatives, but simpler and more maintainable

### Template Strategy: Embedded

**Decision**: Embed templates directly in the gem
**Rationale**:
- Self-contained operation
- No external dependencies
- Works offline
- Consistent across installations

**Alternatives considered**: Download from GitHub, symlink to master repo
**Trade-offs**: Requires gem updates for template changes, but simpler distribution

### Holocron Detection: Directory-Based

**Decision**: Use `_memory/` directory presence for holocron detection
**Rationale**:
- Simple and reliable
- No configuration files to manage
- Self-contained and portable
- Easy to understand and debug

**Alternatives considered**: Configuration files, metadata files, symlinks
**Trade-offs**: Less metadata available, but much simpler and more reliable

### Command Structure: Modular

**Decision**: Separate command classes in Commands namespace
**Rationale**:
- Clean separation of concerns
- Easy to test individual commands
- Simple to add new commands
- Maintainable codebase

**Alternatives considered**: Monolithic CLI class, separate gems per command
**Trade-offs**: More files to manage, but better organization

## Data Flow

### Initialization Flow

1. User runs `holo init my-project`
2. CLI parses arguments and options
3. Init command validates input
4. Template manager creates directory structure
5. Template manager copies embedded templates
6. Success message is displayed

### Validation Flow

1. User runs `holo doctor my-project`
2. CLI parses arguments and options
3. Doctor command detects holocron by `_memory/` directory
4. Doctor command checks directory structure
5. Doctor command validates required files
6. Doctor command checks file permissions
7. Results are displayed to user

### Context Refresh Flow

1. User runs `holo context-refresh --name "reason"`
2. CLI parses arguments and options
3. Context command validates input
4. Context command creates timestamped filename
5. Context command generates template content
6. File is written to context_refresh directory
7. Success message is displayed

## Error Handling

### Error Types

1. **User errors** - Invalid arguments, missing files
2. **System errors** - Permission denied, disk full
3. **Holocron detection errors** - Missing `_memory/` directory
4. **Template errors** - Missing templates, write failures

### Error Handling Strategy

- **Graceful degradation** - Continue operation when possible
- **Clear error messages** - Explain what went wrong and how to fix it
- **Exit codes** - Use appropriate exit codes for different error types
- **Logging** - Log errors for debugging (future enhancement)

## Security Considerations

### File System Access

- **Read-only operations** - Most operations only read files
- **Write permissions** - Only write to specified directories
- **Path validation** - Prevent directory traversal attacks
- **Permission checks** - Verify write permissions before operations

### Configuration Security

- **YAML safety** - Use safe YAML parsing
- **Input validation** - Validate all user inputs
- **Path sanitization** - Sanitize file paths
- **No eval** - Never use eval or similar dangerous operations

## Performance Considerations

### File Operations

- **Batch operations** - Group file operations when possible
- **Lazy loading** - Load files only when needed
- **Caching** - Cache frequently accessed data (future enhancement)
- **Streaming** - Use streaming for large files (future enhancement)

### Memory Usage

- **Minimal memory footprint** - Load only necessary data
- **Garbage collection** - Let Ruby handle memory management
- **No memory leaks** - Avoid holding references to large objects

## Testing Strategy

### Unit Tests

- **Command testing** - Test each command in isolation
- **Template testing** - Test template generation
- **Validation testing** - Test input validation
- **Error testing** - Test error conditions

### Integration Tests

- **End-to-end testing** - Test complete workflows
- **File system testing** - Test with real file operations
- **CLI testing** - Test command-line interface
- **Cross-platform testing** - Test on different operating systems

### Test Data

- **Temporary directories** - Use temporary directories for tests
- **Mock objects** - Mock external dependencies
- **Test fixtures** - Use consistent test data
- **Cleanup** - Clean up after tests

## Future Architecture Considerations

### Plugin System

- **Command plugins** - Allow custom commands
- **Template plugins** - Allow custom templates
- **Validation plugins** - Allow custom validation rules
- **Integration plugins** - Allow integration with other tools

### Cloud Integration

- **Remote templates** - Download templates from cloud
- **Sync capabilities** - Synchronize with cloud storage
- **Collaboration** - Support for team collaboration
- **Backup** - Cloud backup and recovery

### AI Integration

- **Background agent** - Automatic maintenance and updates
- **Decision detection** - Automatically detect and log decisions
- **Progress tracking** - Automatic progress updates
- **Context suggestions** - Suggest when context refreshes are needed

## Dependencies

### Runtime Dependencies

- **thor** (~> 1.3) - CLI framework
- **tty-prompt** (~> 0.23) - Interactive prompts
- **tty-file** (~> 0.10) - File operations
- **colorize** (~> 0.8) - Colored output

### Development Dependencies

- **rspec** (~> 3.12) - Testing framework
- **rake** (~> 13.0) - Build tool
- **rubocop** (~> 1.50) - Code style checker

### System Requirements

- **Ruby 3.1+** - Minimum Ruby version
- **POSIX-compatible OS** - Works on macOS, Linux, Windows with WSL
- **File system access** - Read/write access to project directories

## Conclusion

Holocron's architecture is designed to be simple, reliable, and extensible. The modular design makes it easy to add new features, while the self-contained approach ensures it works consistently across different environments.

The architecture supports the project's goals of providing persistent memory for AI assistants while remaining simple enough for users to understand and modify as needed.
