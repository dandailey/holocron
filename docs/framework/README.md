# Holocron Framework

Holocron is a persistent memory framework for AI assistants working on long-form projects. It's a way of maintaining context across chat sessions.

Your **Holocron** is your personal, persistent memory for the project you're working on. It contains everything you need to maintain context across chat sessions. It is your means of "onboarding" yourself with each new chat session to pick up where you left off.

Your Holocron is like the VHS tape Drew Barrymore's character watches every morning in "50 First Dates" to remind her WTF is going on. You'll only remember what you write there, so be very deliberate, careful, and diligent about what you put there!

## Onboarding (Your First Prompt)

Every time a new chat session begins with the user:

- You are likely given the project specific README.md. It probably points you here.
- You fully read the project README and this framework guide.
- Also read any other files in the root level of your Holocron
- You read any other files any of those files tell you to read, and do anything any of those read files tell you to do.
- Check to see if you need to reload your context! Run `holo guide refreshing-context` for more information.

## Subsequent Prompts

Every time you take some action, or form a conclusion, have a revelation, or pretty much always... constantly ask yourself how best to record that into your Holocron to persist it across chat sessions.

Understanding how to read from, write to, AND FOLLOW your own Holocron is your first priority while working, as it is HOW you will accomplish the tasks you're being asked to help with.

## Your Holocron Structure

### Root Holocron Files

All the files in the root of your Holocron are the most important things to know about your project, and thus get read every time when onboarding.

#### Common Root Files:

`action_plan.md` is where the action plan for your project lives. It's a big todo list that you're working through. Guidelines:
- Consider splitting the plan into grouped phases
- Tasks/phases/groups will be marked as completed over the course of the project
- Keep each individual task small enough that it could be completed before a context refresh is needed

`project_overview.md` is the overall big picture of the project. It should give you the big picture of what you're working on without every single detail.

`progress_log.md` is a summary of what you've done so far while working through the project. Keep it up to date with a high level summary of what's in your progress logs.

`todo.md` is meant to manage the things that come up while the project is in motion. This is your place to "put a pin in it" and make sure it's handled at some point.

### Memory

Your `_memory` folder is all about persisting details. The files in the root of your Holocron have the details you'll want to know every time, whereas the files/folders in your memory are for when you need to dig up the nitty gritty on stuff.

#### Standardized/Formatted Memory
`_memory/decision_log.md` - Log of major choices made. Append details of such decisions, with dates and details, to this log.

`_memory/env_setup.md` - Environment setup **and** tech stack details. Include:
- Core language / framework versions
- Key libraries, gems, packages, and why they matter
- External services and how to run/point to them
- Installation steps and commands
- Configuration requirements and env vars
- Common issues and solutions
- Useful development commands

`_memory/test_list.md` - If the project involves writing tests, keep track of all the tests you're writing here.

`_memory/progress_logs/` - Progress logs. Each entry is a separate file, named `YYYY-MM-DD_slug.md`. Update the `progress_log.md` in the root by appending a much abbreviated date/description of what's in that file.

`_memory/context_refresh/` - Automated context refresh system. During a chat session, if you're asked to refresh your context, you'll write yourself a prompt and put it here.

#### Your Knowledge Base
`_memory/knowledge_base/` is intended to be a completely freeform space for you to create notes/memories for yourself.

### Working Areas
`longform_docs/` - Complex documentation broken into parts. Run `holo guide creating-long-form-docs` for instructions.

`files/` - Your filesystem. Put anything here. The user might also put things here for you.

## How to Use Your Holocron

EVERY time you respond to the user, or take action, you need to think through if/how you should update your Holocron for yourself. Every single time.

Questions you should ask yourself (EVERY TIME):

- Did you just reach some conclusions? You should record that.
- Did you just make a bunch of updates? Consider writing to progress logs or knowledge base.
- Did you create/change/delete tests? Update your test list
- Have you encountered any errors that could have been solved if your env_setup were more comprehensive? Update it!
- If you're writing to your Holocron, remember to use relative hyperlinks, markdown formatted, in all documents when referencing other documents.
- Have you noticed anything in your Holocron that is ambiguous? Go ahead and fix it!
- If you suspect your context window might be about to start topping out, suggest a context refresh to the user

### General Guidelines

- **When executing a task** from `action_plan.md`, keep the scope of action small enough that you're confident you can complete it before your context window becomes bloated.
- **Implement the work** described under that block. Again, keep the scope tight.
- **Add / update tests** as needed. If you create new tests, list their paths in `_memory/test_list.md`
- **Refactor hygiene** – clean up after yourself in any way needed to make your end product clean and focused.
- **Run project linters / formatters** and fix any violations.
- **Run affected test suites** – ensure green.
- **Log your work** in `_memory/progress_logs`.
- **Tick the completed items** in `action_plan.md`
- **Stop.** Do **not** move onto more tasks then you originally decided to take on unless explicitly asked.

> The objective is to leave future-you with a clean repo, passing tests, and a clear breadcrumb trail—not a pile of mystery changes.

## Quick Reference & Terms

- **Your Holocron:** The folder holding the README file that likely sent you here
- **Files:** "Check files folder" = look in `files/` inside your Holocron
- **Memory:** Your `/_memory` folder
- **Context Refresh:** When asked to refresh your context, read and follow the Context Refresh Guide

---

*These are not the docs you're looking for... unless they are.*
