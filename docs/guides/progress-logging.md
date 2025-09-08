# Progress Logging Guide

When you need to document significant work that was completed, use the `holo progress` command to create structured progress log entries.

## Overview

Progress logging captures what was accomplished in a session or work period. It creates both a detailed log file and updates the main progress log with a verbose, scannable summary.

## When to Use Progress Logging

- **After completing significant work** - features, bugs, architecture changes
- **At the end of a work session** - document what was accomplished
- **After reaching milestones** - mark important progress points
- **When asked specifically** - "update progress log" or "log this work"

## How to Use Progress Logging

### CLI Command (Recommended)

**Use this approach for all progress logging:**

```bash
holo progress "Brief summary of work" --slug "descriptive_slug" --content "Full detailed content"
```

**This single command handles everything automatically:**
- Creates detailed log file in `_memory/progress_logs/`
- Updates main `progress_log.md` with verbose summary
- No manual file editing or management required
- Ensures consistent formatting and structure

### Parameters
- **`SUMMARY`** (required): Brief description of what was accomplished
- **`--slug=SLUG`**: Custom filename slug (default: progress_update)
- **`--name=SLUG`**: Alias for --slug
- **`--content=CONTENT`**: Full detailed content (default: uses SUMMARY)
- **`--full_content=CONTENT`**: Alias for --content

### Examples
```bash
# Basic usage
holo progress "Added user authentication system" --slug "auth_feature"

# With detailed content
holo progress "Fixed critical bug in payment processing" --slug "payment_bug_fix" --content "Identified and resolved race condition in payment validation that was causing duplicate charges. Implemented proper locking mechanism and added comprehensive test coverage."

# With custom slug
holo progress "Refactored database layer" --slug "db_refactor" --content "Complete refactor of database access layer to use repository pattern. Improved testability and maintainability while maintaining backward compatibility."
```

## Content Requirements

### Main Progress Log Entry
The main progress log entry should be:
- **Verbose enough for high-level scanning** - you should understand what was accomplished without reading the detailed file
- **Use markdown formatting** - headers, bullet points, paragraphs for clarity
- **Include key details** - what was built, how it works, why it matters
- **Be comprehensive** - cover all significant aspects of the work

### Detailed Log File
The detailed log file should be:
- **Extremely comprehensive** - like a complete summary you'd give after finishing major work
- **Include technical details** - implementation specifics, architectural decisions
- **Cover impact and context** - what this enables, what problems it solves
- **Document next steps** - what should happen next as a result

## What to Include

### Always Include
- **What was accomplished** - specific features, fixes, changes
- **How it was implemented** - technical approach, patterns used
- **Why it matters** - impact, benefits, problems solved
- **Key decisions made** - architectural choices, trade-offs
- **Files modified** - specific filepaths and what changed
- **Testing status** - what's tested, what still needs testing

### Include When Relevant
- **Dependencies added** - new packages, versions, requirements
- **Configuration changes** - environment variables, settings
- **Documentation updates** - what was documented and why
- **Performance improvements** - speed, memory, efficiency gains
- **Security considerations** - vulnerabilities addressed, security improvements
- **Breaking changes** - what might affect other parts of the system

## Content Structure

### Main Log Entry Structure
```markdown
## YYYY-MM-DD: Brief Summary

Comprehensive description of what was accomplished. Include:
- Key features implemented
- Technical approach taken
- Major decisions made
- Impact and benefits
- Any important context

*Detailed log: `_memory/progress_logs/YYYY-MM-DD_slug.md`*
```

### Detailed Log Structure
```markdown
# Brief Summary

**Date:** YYYY-MM-DD HH:MM:SS
**Summary:** Brief description

## Details

Comprehensive technical details covering:
- Implementation specifics
- Architecture decisions
- Code patterns used
- Testing approach
- Performance considerations

## Impact

What this work enables or improves:
- New capabilities
- Performance gains
- Maintainability improvements
- User experience enhancements

## Next Steps

What should happen next as a result of this work:
- Follow-up tasks
- Integration work
- Testing needs
- Documentation updates
```

## Best Practices

### Be Comprehensive
- **Don't leave out important work** - if it was significant, document it
- **Include technical details** - future-you needs to understand the implementation
- **Explain the reasoning** - why decisions were made, what alternatives were considered
- **Document the impact** - what this work enables or improves

### Use Clear Structure
- **Use markdown formatting** - headers, lists, code blocks for clarity
- **Be specific** - avoid vague descriptions, include concrete details
- **Group related work** - organize by feature, component, or logical grouping
- **Include context** - explain the broader picture, not just the immediate work

### Think Like Future-You
- **What would you need to know** to understand what was accomplished?
- **What decisions were made** that could affect future work?
- **What files or areas** need attention next?
- **What problems were solved** and how?

## Common Scenarios

### After Completing a Feature
```bash
holo progress "Implemented user profile management" --slug "user_profiles" --content "Complete user profile system including: 1) Profile model with validation, 2) REST API endpoints for CRUD operations, 3) Frontend components for profile editing, 4) Image upload with S3 integration, 5) Comprehensive test coverage. Uses repository pattern for data access and includes proper error handling and validation."
```

### After Fixing Bugs
```bash
holo progress "Fixed memory leak in background jobs" --slug "memory_leak_fix" --content "Identified and resolved memory leak in background job processing. Root cause was improper cleanup of database connections in long-running jobs. Implemented connection pooling and proper resource cleanup. Added monitoring to prevent future issues."
```

### After Architecture Changes
```bash
holo progress "Refactored to microservices architecture" --slug "microservices_refactor" --content "Major architectural refactor splitting monolith into microservices. Created separate services for user management, payment processing, and notification delivery. Implemented API gateway for service communication and added service discovery. Maintained backward compatibility during transition."
```

### After Research/Exploration
```bash
holo progress "Evaluated database migration strategies" --slug "db_migration_research" --content "Comprehensive research into database migration strategies for large-scale data migration. Evaluated tools, approaches, and risks. Selected incremental migration approach with dual-write pattern. Created detailed migration plan and timeline."
```

## Integration with Other Commands

### With Context Refreshes
Progress logs complement context refreshes:
- **Progress logs** document what was accomplished
- **Context refreshes** capture current state and next steps
- Use both for complete session documentation

### With Offboarding
Progress logging is part of the complete offboarding process:
- Update progress logs for work accomplished
- Create context refresh for current state
- Update other Holocron files as needed

## Troubleshooting

### If You're Unsure What to Document
- Ask: "What would I need to know to understand what was accomplished?"
- Focus on significant work, not minor changes
- When in doubt, err on the side of documenting

### If Content Seems Too Verbose
- Remember: main log should be scannable but comprehensive
- Detailed log should be extremely thorough
- Better to over-document than under-document

### If You're Missing Information
- Review recent commits or changes
- Check what files were modified
- Consider what decisions were made
- Think about what problems were solved

---

**Remember:** Progress logging is about capturing what was accomplished so future-you can understand the work and its impact. Be comprehensive, be specific, and think about what you'd need to know to pick up where you left off.
