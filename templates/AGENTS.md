# Agent Instructions

This project uses Context Engineering files to keep AI collaboration state outside chat history.

## Required Startup

Before making changes, read these files if they exist:

- `CLAUDE.md` for project goals, stack, commands, and current conventions
- `ARCHITECTURE.md` for system design and data flow
- `DECISIONS.md` for accepted and rejected technical decisions
- `TASKS.md` for current work
- `memory/current_state.md` for the latest project state
- `memory/bugs.md` for known issues

## Working Rules

- Prefer existing project patterns over new abstractions.
- Record important technical decisions in `DECISIONS.md`.
- Record non-obvious bugs or lessons in `memory/bugs.md` or `memory/lessons_learned.md`.
- Keep `TASKS.md` aligned with the actual work state.
- Use `prompts/` as the source of project coding, style, and review guidance.

## End of Session

When wrapping up work, update:

- `memory/current_state.md`
- `memory/daily_log.md`
- `TASKS.md`
- `memory/bugs.md` if bugs changed
- `memory/lessons_learned.md` if a reusable lesson was learned
