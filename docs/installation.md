# Installation Guide

This guide will help you install Holocron and get it working on your system.

## Prerequisites

- **Ruby 3.1+** - Holocron requires Ruby 3.1 or higher
- **Git** - For cloning the repository (if installing from source)

## Installation Methods

### Method 1: RubyGems (Recommended)

The easiest way to install Holocron is through RubyGems:

```bash
gem install holocron
```

### Method 2: From Source

If you want to install from source or contribute to development:

```bash
# Clone the repository
git clone https://github.com/dandailey/holocron.git
cd holocron

# Install dependencies
bundle install

# Build and install the gem
gem build holocron.gemspec
gem install ./holocron-0.1.0.gem
```

### Method 3: Using Bundler

For project-specific installation:

```bash
# Add to your Gemfile
gem 'holocron'

# Install
bundle install

# Use with bundle exec
bundle exec holo init my-project
```

## PATH Setup

After installation, you may need to add the gem's bin directory to your PATH.

### Check if Holocron is in your PATH

```bash
holo version
```

If you get "command not found", you need to add the gem's bin directory to your PATH.

### Find the gem's bin directory

```bash
gem environment | grep "EXECUTABLE DIRECTORY"
```

### Add to your shell profile

**For zsh (macOS default):**
```bash
echo 'export PATH="$(gem environment | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d " "):$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For bash:**
```bash
echo 'export PATH="$(gem environment | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d " "):$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**For fish:**
```fish
set -U fish_user_paths (gem environment | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d " ")
```

## Alternative: Use with Bundler

If you don't want to modify your PATH, you can always use Holocron with Bundler:

```bash
# In any directory
bundle exec holo init my-project
```

## Verify Installation

Test that everything is working:

```bash
# Check version
holo version

# Initialize a test project
holo init test-project

# Validate the project
holo doctor test-project

# Clean up
rm -rf test-project
```

You should see:
- Version number displayed
- Successful project initialization
- "All checks passed" from doctor

## Troubleshooting

### "command not found: holo"

This means the gem's bin directory isn't in your PATH. See the [PATH Setup](#path-setup) section above.

### "can't find gem holocron"

This usually means the gem wasn't installed properly. Try:
1. Uninstall and reinstall: `gem uninstall holocron && gem install holocron`
2. Check Ruby version: `ruby --version` (should be 3.1+)
3. Use bundler: `bundle exec holo version`

### Permission errors

If you get permission errors during installation:
- Use `--user` flag: `gem install --user holocron`
- Or install system-wide: `sudo gem install holocron`

### Ruby version issues

If you're using a Ruby version manager (rbenv, rvm, chruby):
- Make sure you're using Ruby 3.1+
- Reinstall the gem after switching Ruby versions
- Check that your version manager is properly configured

## Next Steps

Once installation is complete:

1. **[Read the Commands Reference](commands.md)** - Learn how to use all the commands
2. **[Initialize your first project](commands.md#init)** - Create a Holocron for your project
3. **[Explore the Roadmap](roadmap.md)** - See what's coming next

## Getting Help

If you're still having trouble:

- Check the [Troubleshooting](troubleshooting.md) guide
- Open an [issue on GitHub](https://github.com/dandailey/holocron/issues)
- Join the [discussions](https://github.com/dandailey/holocron/discussions)
