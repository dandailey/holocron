# Troubleshooting

This guide helps you resolve common issues with Holocron.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Command Issues](#command-issues)
- [File System Issues](#file-system-issues)
- [Configuration Issues](#configuration-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

## Installation Issues

### "command not found: holo"

**Problem**: The `holo` command is not found in your PATH.

**Solutions**:

1. **Check if gem is installed**:
   ```bash
   gem list holocron
   ```

2. **Find the gem's bin directory**:
   ```bash
   gem environment | grep "EXECUTABLE DIRECTORY"
   ```

3. **Add to PATH**:
   ```bash
   # For zsh (macOS default)
   echo 'export PATH="$(gem environment | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d " "):$PATH"' >> ~/.zshrc
   source ~/.zshrc
   
   # For bash
   echo 'export PATH="$(gem environment | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d " "):$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Use with bundler**:
   ```bash
   bundle exec holo version
   ```

### "can't find gem holocron"

**Problem**: Ruby can't find the holocron gem.

**Solutions**:

1. **Check Ruby version**:
   ```bash
   ruby --version
   # Should be 3.1 or higher
   ```

2. **Reinstall the gem**:
   ```bash
   gem uninstall holocron
   gem install holocron
   ```

3. **Check gem installation directory**:
   ```bash
   gem environment
   ```

4. **Use bundler**:
   ```bash
   bundle exec holo version
   ```

### Permission errors during installation

**Problem**: Permission denied when installing the gem.

**Solutions**:

1. **Install for user only**:
   ```bash
   gem install --user holocron
   ```

2. **Install system-wide**:
   ```bash
   sudo gem install holocron
   ```

3. **Check gem directory permissions**:
   ```bash
   ls -la $(gem environment | grep "USER INSTALLATION DIRECTORY" | cut -d: -f2 | tr -d " ")
   ```

## Command Issues

### "Invalid arguments" error

**Problem**: Command arguments are not recognized.

**Solutions**:

1. **Check command syntax**:
   ```bash
   holo --help
   holo init --help
   ```

2. **Verify argument format**:
   ```bash
   # Correct
   holo init my-project
   
   # Incorrect
   holo init --project my-project
   ```

3. **Check option names**:
   ```bash
   # Correct
   holo context-new "reason"
   
   # Incorrect
   holo context new "reason"
   ```

### Command hangs or freezes

**Problem**: Command appears to hang without completing.

**Solutions**:

1. **Check for file system issues**:
   ```bash
   df -h  # Check disk space
   ```

2. **Check permissions**:
   ```bash
   ls -la my-project/
   ```

3. **Kill and retry**:
   ```bash
   # Press Ctrl+C to cancel
   # Then retry the command
   ```

4. **Use verbose mode** (if available):
   ```bash
   holo init --verbose my-project
   ```

### "No such file or directory" error

**Problem**: Command can't find required files.

**Solutions**:

1. **Check if directory exists**:
   ```bash
   ls -la my-project/
   ```

2. **Verify file permissions**:
   ```bash
   ls -la my-project/_memory/
   ```

3. **Recreate the Holocron**:
   ```bash
   rm -rf my-project
   holo init my-project
   ```

## File System Issues

### Permission denied errors

**Problem**: Can't read or write files.

**Solutions**:

1. **Check file permissions**:
   ```bash
   ls -la my-project/
   ```

2. **Fix permissions**:
   ```bash
   chmod -R 755 my-project/
   ```

3. **Check ownership**:
   ```bash
   ls -la my-project/
   # Make sure you own the files
   ```

4. **Use sudo if necessary**:
   ```bash
   sudo chown -R $USER:$USER my-project/
   ```

### "Directory not empty" error

**Problem**: Can't create directory because it already exists.

**Solutions**:

1. **Check what's in the directory**:
   ```bash
   ls -la my-project/
   ```

2. **Remove existing directory**:
   ```bash
   rm -rf my-project
   holo init my-project
   ```

3. **Use different directory name**:
   ```bash
   holo init my-project-new
   ```

### File corruption

**Problem**: Files appear corrupted or unreadable.

**Solutions**:

1. **Check file integrity**:
   ```bash
   file my-project/README.md
   ```

2. **Recreate the Holocron**:
   ```bash
   rm -rf my-project
   holo init my-project
   ```

3. **Check disk for errors**:
   ```bash
   fsck /dev/disk  # Linux/macOS
   ```

## Configuration Issues

### "Invalid YAML" error

**Problem**: Configuration file has invalid YAML syntax.

**Solutions**:

1. **Check YAML syntax**:
   ```bash
   cat .holocron.yml
   ```

2. **Validate YAML**:
   ```bash
   ruby -ryaml -e "YAML.load_file('.holocron.yml')"
   ```

3. **Recreate configuration**:
   ```bash
   rm .holocron.yml
   holo init .
   ```

### "Missing configuration" error

**Problem**: Configuration file is missing or not found.

**Solutions**:

1. **Check if file exists**:
   ```bash
   ls -la .holocron.yml
   ```

2. **Recreate configuration**:
   ```bash
   holo init .
   ```

3. **Check working directory**:
   ```bash
   pwd
   # Make sure you're in the right directory
   ```

### Configuration not loading

**Problem**: Configuration changes aren't being applied.

**Solutions**:

1. **Check file permissions**:
   ```bash
   ls -la .holocron.yml
   ```

2. **Verify YAML syntax**:
   ```bash
   ruby -ryaml -e "YAML.load_file('.holocron.yml')"
   ```

3. **Restart the command**:
   ```bash
   # Configuration is loaded fresh each time
   holo doctor
   ```

## Performance Issues

### Slow command execution

**Problem**: Commands take too long to complete.

**Solutions**:

1. **Check disk space**:
   ```bash
   df -h
   ```

2. **Check system resources**:
   ```bash
   top
   # Look for high CPU or memory usage
   ```

3. **Check file system**:
   ```bash
   # For large directories
   find my-project -type f | wc -l
   ```

4. **Use smaller directories**:
   ```bash
   # Break large projects into smaller ones
   holo init my-project-part1
   holo init my-project-part2
   ```

### Memory usage issues

**Problem**: High memory usage during operations.

**Solutions**:

1. **Check memory usage**:
   ```bash
   ps aux | grep holo
   ```

2. **Restart the command**:
   ```bash
   # Kill the process and retry
   pkill holo
   holo doctor my-project
   ```

3. **Check for memory leaks**:
   ```bash
   # Monitor memory usage over time
   while true; do ps aux | grep holo; sleep 1; done
   ```

## Getting Help

### Self-Diagnosis

1. **Check version**:
   ```bash
   holo version
   ```

2. **Check system info**:
   ```bash
   ruby --version
   gem --version
   uname -a
   ```

3. **Check gem info**:
   ```bash
   gem list holocron
   gem info holocron
   ```

4. **Check file permissions**:
   ```bash
   ls -la my-project/
   ```

### Debug Mode

Enable debug output (if available):

```bash
# Set environment variable
export HOLOCRON_DEBUG=1
holo init my-project
```

### Log Files

Check for log files:

```bash
# Look for log files in common locations
ls -la ~/.holocron/
ls -la /tmp/holocron*
ls -la /var/log/holocron*
```

### Community Support

1. **GitHub Issues**: [Report bugs and request features](https://github.com/dandailey/holocron/issues)
2. **GitHub Discussions**: [Ask questions and get help](https://github.com/dandailey/holocron/discussions)
3. **Documentation**: Check the [commands reference](commands.md) and [installation guide](installation.md)

### Reporting Issues

When reporting issues, include:

1. **System information**:
   ```bash
   ruby --version
   gem --version
   uname -a
   ```

2. **Holocron version**:
   ```bash
   holo version
   ```

3. **Command that failed**:
   ```bash
   holo init my-project
   ```

4. **Error message**: Copy the exact error message
5. **Steps to reproduce**: What you did before the error
6. **Expected behavior**: What you expected to happen
7. **Actual behavior**: What actually happened

### Common Solutions

| Problem | Solution |
|---------|----------|
| Command not found | Add gem bin directory to PATH |
| Permission denied | Check file permissions and ownership |
| Invalid YAML | Fix YAML syntax or recreate config |
| Directory not empty | Remove existing directory or use different name |
| Slow performance | Check disk space and system resources |
| Memory issues | Restart command or check for memory leaks |

---

*If you're still having trouble, please open an issue on GitHub with the information above.*
