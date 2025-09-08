# Contributing to Holocron

Thank you for your interest in contributing to Holocron! This guide will help you get started with contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Process](#contributing-process)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)
- [Types of Contributions](#types-of-contributions)
- [Questions?](#questions)

## Code of Conduct

This project follows a simple code of conduct:

- **Be respectful** - Treat everyone with respect and kindness
- **Be constructive** - Provide helpful feedback and suggestions
- **Be patient** - Remember that everyone is learning and growing
- **Be inclusive** - Welcome contributors from all backgrounds and experience levels

## Getting Started

### Prerequisites

- Ruby 3.1 or higher
- Git
- Basic familiarity with Ruby and command-line tools

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/holocron.git
   cd holocron
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/dandailey/holocron.git
   ```

## Development Setup

### Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Initialize your working memory
holo contribute

# Verify installation
holo version
```

### Run Tests

```bash
# Run the test suite
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation
```

### Build and Test Gem

```bash
# Build the gem
gem build holocron.gemspec

# Install locally for testing
gem install ./holocron-0.1.0.gem

# Test the installed gem
holo version
```

## Contributing Process

### 1. Choose an Issue

- Look for issues labeled "good first issue" for beginners
- Check the [roadmap](roadmap.md) for planned features
- Use `holo suggest` to submit new ideas

### 2. Create a Branch

```bash
# Create a new branch for your feature
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/issue-description
```

### 3. Make Changes

- Write your code following the [code style](#code-style) guidelines
- Add tests for new functionality
- Update documentation as needed
- Test your changes thoroughly

### 4. Test Your Changes

```bash
# Run the test suite
bundle exec rspec

# Test the CLI commands
holo init test-project
holo doctor test-project
rm -rf test-project

# Check code style
bundle exec rubocop
```

### 5. Commit Your Changes

```bash
# Add your changes
git add .

# Commit with a descriptive message
git commit -m "Add feature: brief description

More detailed explanation of what was changed and why.
Include any breaking changes or important notes."
```

### 6. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create a pull request on GitHub
```

## Code Style

### Ruby Style

We follow standard Ruby conventions:

- Use 2 spaces for indentation
- Use double quotes for strings
- Use snake_case for methods and variables
- Use PascalCase for classes and modules
- Keep lines under 120 characters
- Use meaningful variable and method names

### File Organization

```
lib/holocron/
├── cli.rb                 # Main CLI class
├── commands/              # Command implementations
│   ├── init.rb
│   ├── doctor.rb
│   └── ...
├── template_manager.rb    # Template management
└── version.rb            # Version information
```

### Documentation

- Document all public methods
- Use YARD-style comments for complex methods
- Include examples in documentation
- Update README and docs for user-facing changes

## Testing

### Test Structure

```
spec/
├── holocron/
│   ├── cli_spec.rb
│   ├── commands/
│   │   ├── init_spec.rb
│   │   ├── doctor_spec.rb
│   │   └── ...
│   └── template_manager_spec.rb
└── spec_helper.rb
```

### Writing Tests

- Write tests for all new functionality
- Test both success and failure cases
- Use descriptive test names
- Mock external dependencies
- Test CLI commands with real file operations

### Example Test

```ruby
RSpec.describe Holocron::Commands::Init do
  let(:temp_dir) { Dir.mktmpdir }
  let(:command) { described_class.new(temp_dir, {}) }

  after { FileUtils.rm_rf(temp_dir) }

  describe "#call" do
    it "creates the directory structure" do
      command.call
      
      expect(Dir.exist?(File.join(temp_dir, "_memory"))).to be true
      expect(Dir.exist?(File.join(temp_dir, "longform_docs"))).to be true
    end

    it "creates required files" do
      command.call
      
      expect(File.exist?(File.join(temp_dir, "README.md"))).to be true
      expect(Dir.exist?(File.join(temp_dir, "_memory"))).to be true
    end
  end
end
```

## Documentation

### User Documentation

- Update relevant docs in the `docs/` directory
- Add examples for new features
- Update command references
- Include troubleshooting information

### Code Documentation

- Document all public methods
- Explain complex algorithms
- Include usage examples
- Update inline comments

### README Updates

- Update feature lists
- Add new installation instructions
- Update examples and usage
- Keep the quick start current

## Types of Contributions

### Bug Reports

- Use the bug report template
- Include steps to reproduce
- Provide expected vs actual behavior
- Include system information

### Feature Requests

- Use the feature request template
- Explain the use case
- Provide examples of how it would work
- Consider the impact on existing users

### Code Contributions

- Fix bugs
- Implement new features
- Improve performance
- Add tests
- Update documentation

### Documentation

- Fix typos and errors
- Improve clarity
- Add examples
- Translate to other languages

### Testing

- Add test cases
- Improve test coverage
- Fix flaky tests
- Add integration tests

## Pull Request Guidelines

### Before Submitting

- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Commit messages are descriptive
- [ ] Branch is up to date with main

### PR Description

Include:
- What changes were made
- Why the changes were needed
- How to test the changes
- Any breaking changes
- Screenshots for UI changes

### Review Process

- All PRs require review
- Address feedback promptly
- Be open to suggestions
- Ask questions if unclear

## Release Process

### Version Bumping

- Patch (0.1.x): Bug fixes
- Minor (0.x.0): New features
- Major (x.0.0): Breaking changes

### Changelog

- Update CHANGELOG.md
- Include all user-facing changes
- Group by type (Added, Changed, Fixed, Removed)
- Include migration notes for breaking changes

## Questions?

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: daniel@example.com (replace with actual contact)

## Recognition

Contributors will be:
- Listed in the README
- Mentioned in release notes
- Added to the contributors list
- Given credit in documentation

Thank you for contributing to Holocron! 🚀
