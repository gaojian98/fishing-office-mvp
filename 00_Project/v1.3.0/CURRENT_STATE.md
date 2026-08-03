# v1.3.0 Current State

## Current Branch

`codex/v1.3-company-organization`

## Current HEAD

`71cbf59045be9e74e54b2a9f91b1d899326b98e6`

## Branch Baseline

- `codex/v1.3-company-organization` and `feature/v1.3.0-office-ai` point to the same HEAD.
- Module 01 and Module 02 source/test changes have been committed locally.
- Current working tree has only v1.3.0 documentation changes waiting for the docs commit.
- Product owner decided to keep using `codex/v1.3-company-organization` as the Module 01 / 02 review branch.
- Safe branch switch is not recommended while these uncommitted changes exist.
- Local `feature/v1.3.0-office-ai` is retained for later consolidation after reviewed commits exist.

## Current Version

`v1.3.0`

## Completed Modules

- Module 01: Company Organization System — REVIEWED – COMMITTED
- Module 02: Career Growth System — REVIEWED – COMMITTED WITH ARCHITECTURE DEBT
- Mutation Types: EXTRACTED – NO RUNTIME IMPLEMENTATION COMMIT
- Runtime Performance Debt: RESOLVED – framework smoke performance gate restored below 800ms
- Long-Term World Evolution Design — DOCUMENTED – WAITING FOR REVIEW

## Planned Next Module

- Module 03: Organization Assignment Runtime Mutation — GO – REQUIRED DEBT RESOLUTION

## Current New Models And Concepts

- `fishing_office_flutter/lib/models/company_organization.dart`
- `CompanyOrganization`
- `Company`
- `Department`
- `Team`
- `Position`
- `OrganizationAssignment`
- `ResidentOrganizationContext`
- `ResidentProfile.organization`
- `ResidentCurrentState.organization`
- `WorldSimulationContext.organizationSnapshot`
- `fishing_office_flutter/lib/models/resident_career.dart`
- `ResidentCareerStatus`
- `ResidentCareerEvent`
- `RecruitmentNeed`
- `PromotionCandidate`
- `ResidentProfile.career`
- `ResidentCurrentState.career`
- `ResidentContext.career`
- `WorldSimulationContext.residentCareerSnapshot`
- `OrganizationAssignment.active`
- `OrganizationMutationRequest`
- `OrganizationMutationResult`
- `OrganizationMutationRecord`
- Runtime organization overrides
- Runtime organization mutation history
- Long-term world evolution design guardrails
- ADR-011 through ADR-021 for world evolution rules
- Architecture guardrails
- Context reading guide

## Recent Modified Files

- `AGENTS.md`
- `00_Project/PROJECT_INDEX.md`
- `00_Project/Module_Manifests/company_organization.md`
- `00_Project/Module_Manifests/resident_career.md`
- `00_Project/v1.3.0/CURRENT_STATE.md`
- `00_Project/v1.3.0/Module_01_Company_Organization_Report.md`
- `00_Project/v1.3.0/Module_02_Career_Growth_Report.md`
- `00_Project/v1.3.0/Module_03_Organization_Assignment_Mutation_Report.md`
- `00_Project/v1.3.0/ROADMAP.md`
- `00_Project/v1.3.0/DESIGN_DECISIONS.md`
- `00_Project/v1.3.0/LONG_TERM_WORLD_EVOLUTION_DESIGN.md`
- `00_Project/v1.3.0/ARCHITECTURE_GUARDRAILS.md`
- `00_Project/v1.3.0/CONTEXT_READING_GUIDE.md`
- `00_Project/v1.3.0/Module_Manifests/organization_assignment_runtime_mutation.md`
- `fishing_office_flutter/lib/models/company_organization.dart`
- `fishing_office_flutter/lib/models/resident_career.dart`
- `fishing_office_flutter/lib/models/resident_config.dart`
- `fishing_office_flutter/lib/core/managers/resident_life_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`
- `fishing_office_flutter/lib/models/interactive_office.dart`
- `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart`
- `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/quest_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart`
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart`
- `fishing_office_flutter/lib/models/resident_story_config.dart`
- `fishing_office_flutter/lib/models/dynamic_event_config.dart`
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/widgets/resident_detail_dialog_test.dart`

## Current Public Interfaces

- `ResidentRuntimeManager.companyOrganization`
- `ResidentRuntimeManager.getResidentOrganization(id)`
- `ResidentRuntimeManager.getResidentOrganizationContext(id)`
- `ResidentRuntimeManager.getResidentsByDepartment(departmentId)`
- `ResidentRuntimeManager.getResidentsByTeam(teamId)`
- `SecondWorldEngine.getCompanyOrganization()`
- `SecondWorldEngine.getResidentOrganizationContext(id)`
- `ResidentContext.organization`
- `WorldSimulationContext.organizationSnapshot`
- `QuestRuntimeManager.recordOrganizationEvent(...)`
- `ResidentRuntimeManager.getResidentCareerStatus(id)`
- `ResidentRuntimeManager.getResidentCareerEvents(id)`
- `ResidentRuntimeManager.applyResidentCareerEvent(id, ...)`
- `ResidentRuntimeManager.getDepartmentRecruitmentNeeds()`
- `ResidentRuntimeManager.getPromotionCandidates(...)`
- `ResidentRuntimeManager.getDepartmentManagers(departmentId)`
- `ResidentRuntimeManager.getTeamLeaders(teamId)`
- `ResidentRuntimeManager.assignResident(...)`
- `ResidentRuntimeManager.promoteResident(...)`
- `ResidentRuntimeManager.transferResident(...)`
- `ResidentRuntimeManager.demoteResident(...)`
- `ResidentRuntimeManager.releasePosition(...)`
- `ResidentRuntimeManager.resignResident(...)`
- `ResidentRuntimeManager.organizationMutationHistory`
- `ResidentRuntimeManager.processedOrganizationMutationIds`
- `SecondWorldEngine.getResidentCareerStatus(id)`
- `SecondWorldEngine.getResidentCareerEvents(id)`
- `SecondWorldEngine.applyResidentCareerEvent(id, ...)`
- `SecondWorldEngine.assignResidentOrganization(...)`
- `SecondWorldEngine.resignResidentOrganization(...)`
- `SecondWorldEngine.getDepartmentRecruitmentNeeds()`
- `SecondWorldEngine.getPromotionCandidates(...)`
- `SecondWorldEngine.getDepartmentManagers(departmentId)`
- `SecondWorldEngine.getTeamLeaders(teamId)`

## Current Design References

- `00_Project/v1.3.0/LONG_TERM_WORLD_EVOLUTION_DESIGN.md`
- `00_Project/v1.3.0/DESIGN_DECISIONS.md`
- `00_Project/v1.3.0/ROADMAP.md`
- `00_Project/v1.3.0/ARCHITECTURE_GUARDRAILS.md`
- `00_Project/v1.3.0/CONTEXT_READING_GUIDE.md`
- `00_Project/v1.3.0/Module_Manifests/organization_assignment_runtime_mutation.md`

## Current Test Baseline

- Latest local validation after Commit 2/3 execution:
  - `flutter analyze` PASS.
  - `flutter test` PASS with 98 tests.
  - `framework_smoke_test` performance gate restored; measured sample `morningDuration=246ms`.
  - Previous release build validation after performance optimization PASS.
  - Previous `git diff --check` PASS.

## Known Limits

- Organization data is derived from existing resident fields when explicit organization fields are absent.
- No company organization UI is included.
- No new JSON type is introduced.
- No reporting graph beyond department manager and team leader position metadata is exposed yet.
- Resident career lifecycle is derived from existing resident data/default rules when no runtime override exists.
- Career events mutate resident career state and persist through existing resident runtime save snapshots.
- Recruitment needs and promotion candidates are runtime recommendations; they do not automatically mutate resident organization assignments yet.
- Resident Detail shows career information inside the existing Office Hub only.
- Career events now route through a unified organization mutation path when they change assignment.
- Organization mutation save data is runtime state only; raw resident config remains unchanged.
- Module 03 implementation-like runtime mutation code is present in the reviewed local source commit as architecture debt for the Module 03 follow-up; Module 03 is not released, pushed, or merged.
- Long-term world evolution rules are documented, but future modules in v1.4.0, v1.5.0, and v2.0.0 remain planned unless explicitly marked implemented in module reports.
- v1.2 release tag, main merge state, and production release files are not modified by this module.

## Current Forbidden Actions

- Do not switch branches while uncommitted v1.3 documentation changes exist.
- Do not push, merge, tag, or modify Railway.
- Do not modify v1.2.0 release baseline.
- Do not enter the next module until branch and review decision is resolved.

## Next Module

GO – REQUIRED DEBT RESOLUTION. Module 03 may continue only after the remaining v1.3 documentation commit is reviewed; it remains required before Office Economy.

## Default Not Required To Re-Read

- `106_Releases/`
- v1.0.0 release reports
- v1.2.0 release package reports
- Pack 01-35 historical reports
- build output directories
- `106_Releases/` unless release or rollback work is explicitly requested

## Latest Review Snapshot

- Module 01 Review: REVIEWED – COMMITTED.
- Module 02 Review: REVIEWED – COMMITTED WITH ARCHITECTURE DEBT.
- Module 03 Readiness: GO – REQUIRED DEBT RESOLUTION.
- Latest validation in Module 01/02 commit execution: analyze PASS, flutter test PASS with 98 tests, performance gate restored to 246ms.
- Commit plan: `00_Project/v1.3.0/MODULE_01_02_COMMIT_PLAN.md`.
- Branch plan: `00_Project/v1.3.0/BRANCH_CONSOLIDATION_PLAN.md`.
