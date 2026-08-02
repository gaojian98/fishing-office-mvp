# Feature 04 Context Plan

Feature 04 placeholder: Career & Promotion Integration.

This file is only a reading plan. Do not start Feature 04 business development from this document alone.

## Planned Manifest Read List

First pass should read these manifests:

- `00_Project/Module_Manifests/resident_runtime.md`
- `00_Project/Module_Manifests/quest_runtime.md`
- `00_Project/Module_Manifests/economy_runtime.md`
- `00_Project/Module_Manifests/relationship_runtime.md`
- `00_Project/Module_Manifests/save_system.md`
- `00_Project/Module_Manifests/world_tick.md`

## Expected Symbols

Search these symbols before opening implementation files:

- `ResidentRuntimeManager`
- `QuestRuntimeManager`
- `EconomyRuntimeManager`
- `RelationshipRuntimeManager`
- `DailySimulationManager`
- `WorldSaveData`
- `WorldSaveManager`
- `WorldTickManager`

## Expected First-Pass Files

READ:

- `AGENTS.md`: repository workflow and reading budget.
- `00_Project/v1.1.0/CURRENT_STATE.md`: current branch, Feature 01-03 state, recent files, and current concepts.
- `00_Project/PROJECT_INDEX.md`: module routing table.
- `00_Project/Module_Manifests/resident_runtime.md`: resident state owner and public interfaces.
- `00_Project/Module_Manifests/quest_runtime.md`: task progress owner and achievement handoff.
- `00_Project/Module_Manifests/economy_runtime.md`: reward and price calculation owner.
- `00_Project/Module_Manifests/relationship_runtime.md`: resident/player relationship rules.
- `00_Project/Module_Manifests/save_system.md`: save fields and compatibility requirements.
- `00_Project/Module_Manifests/world_tick.md`: tick order and runtime execution constraints.
- `fishing_office_flutter/test/framework_smoke_test.dart`: current integration tests, opened only after symbols are identified.

Estimated first-pass read count: 10 files.

Actual implementation read count: 28 repository files.

Reason for exceeding estimate:

- Feature 04 required direct wallet and transaction interfaces for salary records.
- Feature 04 required provider wiring to expose `CareerState`.
- Feature 04 required existing test fixture structure to add regression coverage without scanning unrelated tests.

The additional reads were direct symbol definitions or direct consumers only.

## Avoided Default Reads

Do not read these for the initial Feature 04 pass:

- `106_Releases/`
- v1.0.0 release reports
- Pack 01-35 historical reports
- all `assets/config/*.json`
- all `fishing_office_flutter/lib`
- unrelated pages
- unrelated tests

## Missing Information To Confirm In Feature 04

- Whether career data should reuse existing resident `job`, identity, honor, and task fields.
- Whether a new JSON schema is required by product design.
- Whether promotion is player-facing, resident-facing, or only a world-state tag.
- Whether save compatibility needs a new field or can use existing runtime state metadata.

## Context Location Simulation

Feature 04 can be located without full-repository scanning by:

1. Reading `AGENTS.md`.
2. Reading `CURRENT_STATE.md`.
3. Reading this context plan.
4. Reading the six planned manifests.
5. Searching the eight expected symbols with `rg`.
6. Opening only symbol definitions, direct consumers, and current smoke tests.

The initial location pass should stay within 10 files before implementation files are opened.
