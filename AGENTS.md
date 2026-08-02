# AGENTS.md

This is the first file Codex should read for every task in this repository.

## 1. Project Directory Structure

- `00_Project/`: product bible, standards, roadmap, current state, module manifests, and planning documents.
- `01_DesignSystem/`: UI and visual design-system specifications.
- `02_Pages/`: page-level product references.
- `03_JSON/`: JSON standards and data planning.
- `04_Flutter/`: Flutter engineering references.
- `05_API/`: future API references.
- `05_Content/`: content factory drafts and schemas.
- `06_Test/`: test planning references.
- `07_Release/`: release process references.
- `106_Releases/`: frozen release records; do not read by default.
- `fishing_office_flutter/`: active Flutter project.

## 2. Flutter Project Path

Flutter app root:

- `fishing_office_flutter/`

Run Flutter commands from that directory unless a task explicitly says otherwise.

## 3. Current Development Version

- Current development version: `v1.1.0`
- Current development branch: `feature/v1.1-office-life-schedule`
- Current state file: `00_Project/v1.1.0/CURRENT_STATE.md`

## 4. Authoritative Documents

- Highest Product Specification: `00_Project/SecondWorld_Product_Bible.md`
- Current state: `00_Project/v1.1.0/CURRENT_STATE.md`
- Project index: `00_Project/PROJECT_INDEX.md`
- Module manifests: `00_Project/Module_Manifests/*.md`
- Architecture standard: `00_Project/Standards/Architecture_Standard.md`

Do not use historical release reports as default feature context.

## 5. Core Runtime Entrypoints

- World Clock: `WorldClockManager`
- World Tick: `WorldTickManager`
- Resident Runtime: `ResidentRuntimeManager`
- Resident Decision: `ResidentDecisionManager`
- Dialogue Runtime: `DialogueRuntimeManager`
- Story Runtime: `StoryRuntimeManager`
- Dynamic Event Runtime: `DynamicEventRuntimeManager`
- Daily Simulation: `DailySimulationManager`
- Save System: `WorldSaveManager`
- Unified facade: `SecondWorldEngine`

## 6. Default Forbidden Read Scope

Unless a task explicitly requires it, do not default-read:

- `106_Releases/`
- v1.0.0 release reports
- Pack 01-35 historical reports
- old validation reports
- `build/`
- `.dart_tool/`
- `.git/`
- all `assets` JSON
- all `lib`
- unrelated pages
- unrelated tests
- archived documents

Do not scan the whole repository to understand a single interface.

## 7. Context Reading Budget

First read pass limits:

- Small fix: maximum 10 files.
- Single-module Feature: maximum 18 files.
- Cross-module Feature: maximum 30 files.

Before exceeding budget, output:

- file path
- reason for reading
- direct relationship to the task
- why existing manifests were insufficient

Do not read first and justify later.

## 8. Default Reading Workflow

Every task should follow this order:

1. Read `AGENTS.md`.
2. Read `00_Project/v1.1.0/CURRENT_STATE.md`.
3. Read the task-specified Module Manifest.
4. Use `00_Project/PROJECT_INDEX.md` to locate implementation, config, tests, dependencies, and consumers.
5. Search task symbols with `rg`.
6. Open symbol definition files.
7. Open direct callers or consumers.
8. Open corresponding tests.
9. Start modification.

Forbidden default workflow:

- scan entire repository
- read every architecture document
- read all historical reports
- read all JSON
- read all `lib`

## 9. Symbol-First Search Rules

Prefer searching:

- class names
- interface names
- provider names
- method names
- JSON field names
- test names

Open only:

- symbol definition file
- direct dependency files
- direct consumer files
- corresponding test files

Do not bulk-open files by directory name only.

## 10. File Reading Plan

Before editing, output:

```text
READ:
- path: reason

MODIFY:
- path: reason
```

If additional files are needed later, add the file path and reason before reading it.

## 11. Test Grading Rules

During development:

- Run directly related tests first.
- Use targeted `flutter test` names or files when possible.
- If tests are concentrated in `framework_smoke_test.dart`, record the split recommendation but do not reorganize tests unless asked.

Feature completion validation:

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter build web --release`

Do not run a full release build after every small edit.

## 12. Report And Norm Separation

- `00_Project/Standards/`: stable development standards.
- `00_Project/Module_Manifests/`: fast module summaries.
- `00_Project/v1.1.0/`: current version state and feature reports.
- `106_Releases/`: release, rollback, and production acceptance only.

Historical reports are not ordinary Feature inputs.

## 13. Architecture Rules

- Manager few, Module many.
- Product describes capability; engineering decides implementation.
- Do not create a top-level Manager, Engine, Repository, Runtime, Provider, or UI page unless explicitly required and no existing owner fits.
- UI displays state and calls public interfaces. UI must not directly parse JSON or own business rules.
- Content expansion should be JSON-driven and should not require Flutter code changes.

## 14. Git Safety Rules

- Do not commit unless explicitly asked.
- Do not push unless explicitly asked.
- Do not force push.
- Do not modify tags unless explicitly asked.
- Do not switch away from the feature branch unless the task requires it.
- Never use `git add .` when the task limits file scope.
- Before any commit, show `git status --short`, `git diff --stat`, and exact staged file list.

## 15. Modification Reports

Before changing files, state:

- task scope
- planned read files
- planned modify files
- files intentionally not touched
- validation commands planned

After finishing, report:

- changed files
- module impact
- tests or checks run
- known limits
- no commit/no push confirmation

## 16. Local Editing Rules

- Do not use `perl`.
- Prefer focused edits.
- Do not rewrite unrelated files.
- Do not touch Flutter business code, JSON, UI, Runtime behavior, v1.0.0 release files, or Railway config for documentation-only tasks.
