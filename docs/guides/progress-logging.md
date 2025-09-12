# Progress Logging Guide

When you need to document significant work that was completed, use the `holo progress` command to create structured progress log entries.

## Overview

Progress logging captures what was accomplished in a session or work period. It creates both a detailed log file and updates the main progress log with a verbose, scannable summary.

## When to Use Progress Logging

- **After completing significant work** - features, bugs, architecture changes
- **At the end of a work session (offboarding)** - document what was accomplished
- **After reaching milestones** - mark important progress points
- **When asked specifically** - "update progress log" or "log this work"

## How to Use Progress Logging

### CLI Command (Recommended)

**For simple content (short, no special characters):**
```bash
holo progress "Full detailed content here" --summary "Brief summary" --name "descriptive_name"
```

**For complex content (long, markdown, special characters):**
```bash
# AI agents: Write content directly to buffer file using file writing tools/functions
# File location: _memory/tmp/buffer
# 
# Example content to write:
# ## Major Accomplishments
# 
# ### Feature Implementation
# - **Added user authentication** with JWT tokens
# - **Implemented role-based access control**
# - **Created comprehensive test suite**
# 
# ### Technical Details
# - Used bcrypt for password hashing
# - JWT tokens expire after 24 hours
# - Added middleware for route protection
# - 95% test coverage achieved

# Then use buffer with optional summary and name
holo progress --from-buffer --summary "A paragraph or two to summarize the full writeup of what progress was made" --name "auth_implementation"

# Or minimal usage (auto-generates summary and uses default name)
holo progress --from-buffer
```

**This single command handles everything automatically:**
- Creates detailed log file in `_memory/progress_logs/`
- Updates main `progress_log.md` with verbose summary
- No manual file editing or management required
- Ensures consistent formatting and structure

### Parameters
- **`CONTENT`** (optional): Full detailed content (required if not using --from-buffer)
- **`--summary=SUMMARY`**: Brief summary (auto-generated if not provided)
- **`--name=NAME`**: Custom name for the entry (default: progress_update)
- **`--from-buffer`**: Read content from buffer file - **recommended for complex content**

### Writing Effective Summaries

The summary should strike a balance between being too brief and too verbose. It needs to fully capture what was accomplished at a high level without duplicating the detailed content.

**Good Summary Characteristics:**
- **1-2 paragraphs maximum** - enough space to explain the scope
- **High-level overview** - what was accomplished, not how it was done
- **Bulleted lists when appropriate** - for multiple related accomplishments
- **Clear and scannable** - someone should understand the work without reading details

**Examples of Good Summaries:**

```bash
# Single accomplishment - clear and specific
--summary "Implemented user authentication system with JWT tokens and role-based access control"

# Multiple related accomplishments - use bullets for scannability
--summary "Completed database optimization initiative:
- Query performance improvements (40% faster)
- Index optimization and connection pooling
- Added comprehensive monitoring and alerting"

# Complex work - high-level overview with key outcomes
--summary "Major payment processing refactor improving reliability and maintainability. Split monolithic handler into modular components with proper error handling and retry logic. System now handles 3x more transactions with 99.9% uptime."
```

**Avoid:**
- **Too brief**: "Fixed bug" or "Added feature" (lacks context)
- **Too verbose**: Including technical implementation details (belongs in detailed log)
- **Vague**: "Made improvements" or "Updated code" (doesn't explain what)

### Writing Comprehensive Detailed Content

The detailed content should be as thorough as needed - think of it as a complete technical report or essay. There are no length limits; verbosity is encouraged for the detailed log.

**Detailed Content Should Include:**
- **Full technical implementation details** - how things were built, what approaches were taken
- **Architecture and design decisions** - why certain choices were made
- **Code examples and file locations** - specific implementation details
- **Testing and validation** - what was tested, coverage achieved, edge cases handled
- **Challenges and solutions** - problems encountered and how they were solved
- **Impact and implications** - what this work enables, performance improvements, etc.
- **Future considerations** - what might need attention next, potential improvements

**Think of it as:** A comprehensive technical document that future you (or someone else) could read to fully understand what was accomplished and how.

### Examples
```bash
# Basic usage (simple content)
holo progress "Added user authentication system with JWT tokens and role-based access control" --summary "Implemented user authentication system with JWT tokens and role-based access control" --name "auth_feature"

# With custom summary and name
holo progress "Identified and resolved race condition in payment validation that was causing duplicate charges. Implemented proper locking mechanism and added comprehensive test coverage." --summary "Fixed critical race condition in payment validation that was causing duplicate charges" --name "payment_bug_fix"

# Complex content using buffer (recommended)
# AI agents: Write content directly to buffer file using file writing tools
# File location: _memory/tmp/buffer
# Content example:
# ## Major Refactoring Complete
# 
# ### Database Layer Overhaul
# - **Repository Pattern**: Implemented clean separation between data access and business logic
# - **Query Optimization**: Reduced average query time by 40%
# - **Test Coverage**: Achieved 95% coverage with comprehensive integration tests
# 
# ### Technical Implementation
# - Created `UserRepository` and `OrderRepository` classes
# - Added `DatabaseTransaction` wrapper for atomic operations
# - Implemented `QueryBuilder` for dynamic query construction
# - Added comprehensive error handling and logging
# 
# ### Performance Impact
# - Query response time: 200ms → 120ms average
# - Memory usage: Reduced by 15%
# - Test execution time: 30s → 18s
# 
# ### Breaking Changes
# - Updated all service classes to use repositories
# - Modified API endpoints to handle new error responses
# - Updated documentation and examples

holo progress --from-buffer --summary "Database layer refactoring complete" --name "db_refactor"
```

## Content Requirements

### Main Progress Log Entry
The main progress log entry should be:
- **Verbose enough for high-level scanning** - you should understand what was accomplished without reading the detailed file
- **Include key details** - what was built, how it works, why it matters

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
