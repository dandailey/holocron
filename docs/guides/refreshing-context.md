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

**This single command handles everything automatically:**
- Creates context refresh file in `_memory/context_refresh/`
- Uses timestamped filename (YYYY_MM_DD_HHMMSS format)
- Provides comprehensive template with all necessary sections
- Ready for immediate editing with your preferred editor

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

### Manual Loading
When starting a new session, check for context refresh files in `_memory/context_refresh/` and read the most recent one to get up to speed.

### Automated Loading
Use `holo onboard` to automatically:
- Display the framework guide
- Process any pending context refreshes
- Rename pending files to mark them as executed
- Display the content of processed refreshes

This ensures you never miss a context refresh and automates the file management workflow.
