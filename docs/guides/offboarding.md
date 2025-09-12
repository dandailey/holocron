# Offboarding Guide

When you're asked to "offboard" or "offload" at the end of a chat session, follow this systematic process to properly document everything that happened and prepare for the next session.

## Overview

Offboarding ensures that all important work, decisions, and context from the current session are properly captured in your Holocron for future sessions. This prevents information loss and makes handoffs seamless.

## Step-by-Step Offboarding Process

### 1. Update Progress Logs

Document what was accomplished using the progress logging system:

**For simple content:** `holo progress "Full content here" --summary "Summary" --name "slug"`

**For complex content (recommended):** 
```bash
# AI agents: Write detailed content directly to buffer file using file writing tools
# File location: _memory/tmp/buffer
# Content example:
# ## Major Accomplishments
# [detailed content...]
# 
# Then use:
holo progress --from-buffer --summary "Summary" --name "descriptive_name"
```

**The CLI command handles everything automatically:**
- Creates detailed log file in `_memory/progress_logs/`
- Updates main `progress_log.md` with verbose summary
- No manual file editing required

**For detailed instructions:** Run `holo guide progress-logging`

**Quick reference:**
- Use verbose, comprehensive content for both main log and detailed file
- Include technical details, decisions made, and impact
- Use markdown formatting for clarity
- Think: "What would I need to know to understand what was accomplished?"

### 2. Create Context Refresh

Create a comprehensive handoff summary using the context refresh system:

**Basic usage:** `holo context-refresh`

**With custom name:** `holo context-refresh --name "reason"`

**The CLI command handles everything automatically:**
- Creates properly named, timestamped file in `_memory/context_refresh/`
- No manual editing or file renaming required
- Ready for immediate use by next session

**For detailed instructions:** Run `holo guide refreshing-context`

**Quick reference:**
- Be extremely verbose (10% condensation of entire conversation)
- Cover everything important - don't leave out significant work or decisions
- Use all template sections comprehensively
- Think: "What would I need to know to pick up exactly where we left off?"

### 3. Review and Update Other Holocron Files

Check each of these files and update if there's relevant new information:

#### Decision Log (`_memory/decision_log.md`)
- **When to update:** Major architectural decisions, technology choices, approach changes
- **What to add:** Decision, reasoning, date, impact
- **Example:** "Chose file-based documentation over hardcoded strings for maintainability"

#### Environment Setup (`_memory/env_setup.md`)
- **When to update:** New dependencies, version changes, setup steps, common issues
- **What to add:** Package versions, installation steps, troubleshooting notes
- **Example:** "Added colorize gem for CLI output formatting"

#### Action Plan (`action_plan.md`)
- **When to update:** Tasks completed, new tasks discovered, priority changes
- **What to do:** Mark completed items with [x], add new tasks as needed
- **Example:** "Mark Phase A tasks as completed, add Phase B testing tasks"

#### Project Overview (`project_overview.md`)
- **When to update:** Scope changes, architecture updates, goal modifications
- **What to add:** Updated scope, new features, changed priorities
- **Example:** "Added automated context refresh processing to core features"

#### Todo (`todo.md`)
- **When to update:** New issues discovered, follow-up tasks, technical debt
- **What to add:** Specific actionable items with context
- **Example:** "Write tests for new onboard command"

### 4. Quality Check

Before finishing, verify:
- [ ] Progress log entry created with meaningful summary
- [ ] Context refresh created with current state
- [ ] All major decisions documented
- [ ] Action plan reflects current status
- [ ] No important information left undocumented

### 5. Final Steps

1. **Review the context refresh** - Make sure it accurately captures where you left off
2. **Check for pending context refreshes** - Run `holo onboard` to see if there are any pending refreshes to process
3. **Update progress log summary** - The `holo progress` command automatically updates the main progress log, but verify it looks good

## Command Reference

### Progress Log Command
```bash
# Preferred method (for complex content):
holo progress --from-buffer --summary "Summary" --name "descriptive_name"

# Alternative method (for simple content):
holo progress "Full content here" --summary "Summary" --name "slug_name"
```
**This handles everything automatically** - creates detailed log file and updates main progress log.

### Context Refresh Command
```bash
# Preferred method (for AI agents):
# 1. Write content to _memory/tmp/buffer using file writing tools
# 2. Create context refresh from buffer:
holo context-refresh --from-buffer --name "descriptive_name"
# 3. Clear buffer: holo buffer clear

# Alternative method (with template):
holo context-refresh --name "reason"
```
**Note:** The --from-buffer method provides better control over content formatting and uses the proper _PENDING_ prefix.

### Other Useful Commands
```bash
holo onboard          # Process any pending context refreshes
holo doctor           # Validate Holocron structure
holo framework        # Reference the framework guide
```

## Best Practices

### Be Comprehensive
- Use descriptive slugs that will make sense later
- Include extensive detail in progress logs - main log should be scannable but verbose
- Make context refreshes extremely comprehensive - cover everything important from the session
- Use markdown formatting for clarity and readability

### Document Everything Important
- Only update files when there's actually new information
- Avoid creating empty or generic entries
- Focus on information that will be useful for future sessions
- Don't leave out significant work, decisions, or context

### Stay Organized
- Use consistent naming conventions for slugs
- Make progress log entries verbose with clear structure and formatting
- Use all context refresh template sections comprehensively
- Think like future-you: what would you need to know?

### Think Like Future-You
- What would you need to know to pick up where you left off?
- What decisions were made that could affect future work?
- What files or areas need attention next?

## Common Offboarding Scenarios

### After Completing a Feature
- Progress log: What was built and how
- Context refresh: Current state, next features to work on
- Action plan: Mark completed tasks, add new ones
- Decision log: Any architectural choices made

### After Fixing Bugs
- Progress log: What was broken and how it was fixed
- Context refresh: Current stability, remaining issues
- Environment setup: Any new troubleshooting steps
- Todo: Follow-up testing or monitoring

### After Architecture Changes
- Progress log: What changed and why
- Context refresh: New architecture, migration status
- Decision log: Reasoning for changes
- Project overview: Updated architecture description

### After Research/Exploration
- Progress log: What was learned
- Context refresh: Current understanding, next steps
- Knowledge base: Detailed research notes
- Decision log: Technology choices made

## Troubleshooting

### If You're Unsure What to Document
- Ask: "What would I need to know to continue this work tomorrow?"
- Focus on decisions, progress, and next steps
- When in doubt, err on the side of documenting

### If Files Seem Out of Sync
- Run `holo doctor` to check for issues
- Review recent progress logs to understand current state
- Use `holo onboard` to process any pending context refreshes

### If You're Overwhelmed
- Start with progress log and context refresh (minimum viable offboarding)
- Add other updates as time allows
- Remember: some documentation is better than none

---

**Remember:** The goal is to make the next session seamless. Future-you should be able to run `holo onboard` and immediately understand where things stand and what needs to happen next.
