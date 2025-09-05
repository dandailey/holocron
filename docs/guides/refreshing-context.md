# Refreshing Context

When your context window is getting full or you need to hand off to a future session, create a context refresh file.

## When to Refresh Context

- Your context window is approaching its limit
- You're about to start a complex task that might span multiple sessions
- You've completed a major milestone and want to summarize progress
- You're handing off work to someone else (or future you)

## How to Create a Context Refresh

1. Run: `holo context-new "Brief description of current state"`
2. This creates a timestamped file in `_memory/context_refresh/`
3. Write a comprehensive summary of:
   - What you've accomplished
   - Current state of the project
   - What needs to be done next
   - Any important decisions or discoveries
   - Links to relevant files or resources

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

When starting a new session, check for context refresh files in `_memory/context_refresh/` and read the most recent one to get up to speed.
