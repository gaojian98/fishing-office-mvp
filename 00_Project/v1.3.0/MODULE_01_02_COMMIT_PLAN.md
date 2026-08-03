# v1.3.0 Module 01-02 Commit Plan

## Rules

- Do not use `git add .`.
- Do not use `git add -A`.
- Do not use `git commit -a`.
- Do not push before explicit approval.
- Do not merge, rebase, stash, reset, clean, switch branch, delete branch, modify `main`, modify Railway, or modify v1.2.0 release artifacts.
- Current review branch remains `codex/v1.3-company-organization`.

## Approved Commit Strategy

Product owner selected Scheme 2 because `company_organization.dart` does not have a tracked pre-extraction version in Git. The real commit order is:

1. Module 01 complete implementation.
2. Mutation type extraction.
3. Module 02 career lifecycle.
4. v1.3 documentation.

Commit 1 is allowed to include the complete current `company_organization.dart` because that file is the Module 01 core business model. Commit 2 is the behavior-preserving extraction that moves `OrganizationMutation*` types from that committed file into a dedicated file.

## Commit 1

### Commit message

`feat(organization): add v1.3 company organization foundation`

### Purpose

Add company organization foundation for v1.3:

- `Company`
- `Department`
- `Team`
- `Position`
- `OrganizationAssignment`
- resident organization fields
- default organization initialization
- organization query capability
- save/restore compatibility
- required provider/facade integration
- Module 01 tests
- complete `company_organization.dart` as the Module 01 core model

### Allowed Contents

Commit 1 may include `OrganizationMutation*` type definitions while they are still inline in `company_organization.dart`.

### Forbidden Contents

- Module 03 runtime execution logic
- transaction execution logic
- idempotent execution logic
- job assignment workflow execution
- Career-specific business logic
- Office Economy
- AI Decision

### Files

- `fishing_office_flutter/lib/models/company_organization.dart`
- `fishing_office_flutter/lib/models/resident_config.dart` organization hunks only
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart` organization query/fallback hunks only
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart` organization facade hunks only
- `fishing_office_flutter/lib/core/managers/resident_life_manager.dart` organization propagation hunks only
- `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart` organization condition hunks only
- `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart` organization condition hunks only
- `fishing_office_flutter/lib/core/managers/quest_runtime_manager.dart` organization event/query hunks only
- `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart` organization condition hunks only
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart` organization condition fields only
- `fishing_office_flutter/lib/models/resident_story_config.dart` organization condition fields only
- `fishing_office_flutter/lib/models/dynamic_event_config.dart` organization condition fields only
- `fishing_office_flutter/test/framework_smoke_test.dart` Module 01 tests only

### Validation

After commit:

- `flutter analyze`
- `flutter test test/framework_smoke_test.dart`
- `git show --check HEAD`

## Commit 2

### Commit message

`refactor(organization): extract organization mutation types`

### Purpose

Move only organization mutation value types from `company_organization.dart` into a dedicated file, preserving public behavior.

### Allowed Contents

- mutation enum if present
- mutation request type
- mutation result type
- mutation history/record type
- mutation validation value object if present
- directly related serialization structure
- import/export/part changes required by the extraction

### Forbidden Changes

- class names
- fields
- default values
- JSON keys
- constructor semantics
- equals/hashCode semantics
- save format
- runtime behavior
- world tick order
- public feature behavior

### Files

- `fishing_office_flutter/lib/models/company_organization.dart`
- `fishing_office_flutter/lib/models/organization_mutation.dart`

### Validation

Before commit:

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `git diff --check`

After commit:

- `git show --stat --oneline HEAD`
- `git show --check HEAD`

## Commit 3

### Commit message

`feat(career): add resident career growth lifecycle`

### Purpose

Add resident career lifecycle support:

- `hireDate`
- `careerLevel`
- `salaryLevel`
- `employmentStatus`
- `promotionHistory`
- Hire
- Promotion
- Transfer
- Demotion
- Resignation
- Recruitment
- Career UI display through existing components
- Career save compatibility
- Module 02 tests

### Required Architecture Debt

Career and Organization unified Mutation Runtime remains Module 03 work. This commit must not implement:

- Organization Mutation Runtime
- full transaction rollback
- full position occupation engine
- Office Economy
- AI Decision

### Files

- `fishing_office_flutter/lib/models/resident_career.dart`
- `fishing_office_flutter/lib/models/resident_config.dart` career hunks only
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart` career hunks only
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart` career facade hunks only
- `fishing_office_flutter/lib/models/interactive_office.dart`
- `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart`
- `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart` career condition hunks only
- `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart` career condition hunks only
- `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart` career condition hunks only
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart` career condition fields only
- `fishing_office_flutter/lib/models/resident_story_config.dart` career condition fields only
- `fishing_office_flutter/lib/models/dynamic_event_config.dart` career condition fields only
- `fishing_office_flutter/test/framework_smoke_test.dart` Module 02 tests only
- `fishing_office_flutter/test/widgets/resident_detail_dialog_test.dart`

### Validation

After commit:

- `flutter analyze`
- `flutter test`

## Commit 4

### Commit message

`docs(v1.3): establish world evolution architecture and context`

### Purpose

Record v1.3 review, architecture, context, roadmap, and commit execution state.

### Allowed Files

- `AGENTS.md`
- `00_Project/PROJECT_INDEX.md`
- `00_Project/v1.3.0/**`

### Required Status Language

- Module 01: `REVIEWED – COMMITTED`
- Module 02: `REVIEWED – COMMITTED WITH ARCHITECTURE DEBT`
- Mutation Types: `EXTRACTED – NO RUNTIME IMPLEMENTATION`
- Module 03: `PLANNED – REQUIRED DEBT RESOLUTION`

### Forbidden Claims

- Module 03 implemented
- pushed
- merged
- released

## Final Validation

After all commits:

- `dart format --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `flutter build web --release`
- `git diff --check`
- `git status`
- `git log --oneline -12`

Expected:

- format PASS
- analyze PASS
- tests PASS
- test count >= 98
- release build PASS
- `git diff --check` PASS
- no omitted source
- no unknown source
- no Railway modification
- no v1.2.0 release modification
