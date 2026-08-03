# v1.3.0 Context Reading Guide

## Default Reading Order

1. `AGENTS.md`
2. `00_Project/PROJECT_INDEX.md`
3. `00_Project/v1.3.0/CURRENT_STATE.md`
4. `00_Project/v1.3.0/LONG_TERM_WORLD_EVOLUTION_DESIGN.md`
5. Target Module Manifest
6. Target module direct source files
7. Target module direct tests

## First-Pass Reading Budget

The first read pass may include at most 12 files.

Before reading beyond that budget, output:

- what information is missing
- why more reading is required
- which files will be read
- whether the read would exceed the budget

## Default Forbidden Reads

Do not default-read:

- the whole project
- all manifests
- all JSON
- all tests
- all release reports
- `build/`
- `.dart_tool/`
- `106_Releases/`

## Symbol-First Rule

For implementation checks, search exact symbols first:

- class names
- method names
- interface names
- JSON field names
- test names
- provider names

Then open only:

- symbol definition
- direct caller
- direct consumer
- direct test

## Documentation-Only Tasks

For documentation-only tasks:

- do not open `lib/` or `test/` unless the task explicitly asks to verify implementation details
- do not run Flutter tests unless requested
- use `git diff --check`, `git status --short`, `git diff --stat`, and `git diff --name-only` for validation

## Release Boundary

Do not read or modify v1.2.0 release files unless the task explicitly involves release, rollback, production, or deployment.
