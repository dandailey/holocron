# Refreshing Context

When your context window is getting full or you need to hand off to a future session, create a context refresh file.

## When to Refresh Context

- Your context window is approaching its limit
- You're about to start a complex task that might span multiple sessions
- You've completed a major milestone and want to summarize progress
- You're handing off work to someone else (or future you)

## How to Create a Context Refresh

### CLI Command (Recommended)

**Basic usage:**
```bash
holo context-refresh
```

**With custom name:**
```bash
holo context-refresh --name "auth_milestone_complete"
```

**With buffer content (for AI agents):**
```bash
# 1. Write comprehensive context refresh content to buffer file
# File location: _memory/tmp/buffer
# Content should include all sections below

# 2. Create context refresh from buffer
holo context-refresh --from-buffer --name "descriptive_name"

# 3. Clear buffer when done: holo buffer clear
```

**This command automatically:**
- Creates context refresh file in `_memory/context_refresh/`
- Uses proper `_PENDING_` prefix for automated processing
- Preserves underscores in names (makes them filename-safe)
- Uses timestamped filename (YYYY_MM_DD_HHMMSS format)
- Provides comprehensive template or uses buffer content

## Context Refresh Template

When creating a context refresh, use this comprehensive template:

```markdown
# Context Refresh - [Date]

## Current State
- [What has been completed/accomplished]
- [Current system status]
- [What's working and what's not]
- [Key files and their locations]

## Next Steps
- [Immediate next tasks to work on]
- [Priority order for upcoming work]
- [Dependencies that need to be resolved]

## Important Notes
- [Key technical decisions made]
- [Files that were modified and why]
- [Configuration changes or environment setup]
- [References to other documentation (decision logs, etc.)]

## Context for Next Session
- [What the next AI should focus on first]
- [Any warnings or gotchas to be aware of]
- [Resources or documentation to reference]
- [Current blockers or issues to address]
```

## Example Context Refresh

```markdown
# Context Refresh - 2025-09-05

## Current State
- Completed user authentication system
- Database migrations are ready
- Tests are passing

## Next Steps
- Implement user profile management
- Add password reset functionality
- Write integration tests

## Important Notes
- User model is in `app/models/user.rb`
- Auth controller is in `app/controllers/auth_controller.rb`
- See `_memory/decision_log.md` for auth strategy decisions
```

## Loading Context

### Automated Loading
Use `holo onboard` to automatically:
- Display the framework guide
- Process any pending context refreshes
- Rename pending files to mark them as executed
- Display the content of processed refreshes

This ensures you never miss a context refresh and automates the file management workflow.
