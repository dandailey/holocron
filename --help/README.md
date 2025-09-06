# Your Holocron Bootup Instructions

FIRST THING'S FIRST: if you haven't already, run `holo framework` to understand the Holocron framework and follow any instructions it contains. Go do that now.

## Quick Access
- **Canonical env/setup**: [`_memory/env_setup.md`](_memory/env_setup.md)
- **App-wide decisions**: [`_memory/decision_log.md`](_memory/decision_log.md)
- **Cross-cutting tests**: [`_memory/test_list.md`](_memory/test_list.md)

## Your Holocron Structure

This Holocron contains everything you need to maintain context across chat sessions for this project.

### Root Files (Read Every Session)
- **action_plan.md**: Step-by-step project plan with phases, tasks, and completion checkboxes
- **project_overview.md**: Big picture overview of the project with goals and approach
- **progress_log.md**: High-level summary of work completed with references to detailed logs
- **todo.md**: Overflow tasks and scope creep items that need attention

### Memory Files (Read When Needed)
- **_memory/decision_log.md**: Log of major architectural and technical decisions
- **_memory/env_setup.md**: Development environment, tech stack, and database setup
- **_memory/test_list.md**: List of all tests written with file paths and coverage notes
- **_memory/progress_logs/**: Detailed task logs (YYYY-MM-DD_slug.md format)
- **_memory/context_refresh/**: Automated context refresh files
- **_memory/knowledge_base/**: Freeform wiki space for project knowledge

### Working Areas
- **longform_docs/**: Complex documentation broken into parts
- **files/**: Your filesystem workspace

## How to Use This Holocron

Every time you respond to the user or take action, think about updating your Holocron:

- Did you reach conclusions? Record them in the appropriate memory file
- Did you make updates? Consider writing to progress logs
- Did you create/change/delete tests? Update your test list
- Did you encounter errors? Update env_setup if it could have been prevented
- Did you make decisions? Log them in decision_log.md

Remember: this is YOUR memory. Write what future-you needs to know!
