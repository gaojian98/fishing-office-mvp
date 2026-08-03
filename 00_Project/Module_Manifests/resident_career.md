# resident_career

## Purpose
Expose each resident's career lifecycle inside the existing resident runtime without adding a new top-level Manager, Engine, Repository, or JSON type.

## Main files
- `fishing_office_flutter/lib/models/resident_career.dart`
- `fishing_office_flutter/lib/models/resident_config.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/models/interactive_office.dart`
- `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart`

## Data files
- Existing resident JSON only.
- Optional resident fields: `career`, `hireDate`, `careerLevel`, `promotionHistory`, `salaryLevel`, `employmentStatus`, `performanceScore`, `capabilityScore`, `careerTags`.

## Public interfaces
- `ResidentProfile.career`
- `ResidentCurrentState.career`
- `ResidentRuntimeManager.getResidentCareerStatus(id)`
- `ResidentRuntimeManager.getResidentCareerEvents(id)`
- `ResidentRuntimeManager.applyResidentCareerEvent(id, ...)`
- `ResidentRuntimeManager.assignResident(...)`
- `ResidentRuntimeManager.promoteResident(...)`
- `ResidentRuntimeManager.transferResident(...)`
- `ResidentRuntimeManager.demoteResident(...)`
- `ResidentRuntimeManager.releasePosition(...)`
- `ResidentRuntimeManager.resignResident(...)`
- `ResidentRuntimeManager.getDepartmentRecruitmentNeeds()`
- `ResidentRuntimeManager.getPromotionCandidates(...)`
- `ResidentRuntimeManager.getDepartmentManagers(departmentId)`
- `ResidentRuntimeManager.getTeamLeaders(teamId)`
- `SecondWorldEngine.getResidentCareerStatus(id)`
- `SecondWorldEngine.getResidentCareerEvents(id)`
- `SecondWorldEngine.applyResidentCareerEvent(id, ...)`
- `SecondWorldEngine.assignResidentOrganization(...)`
- `SecondWorldEngine.resignResidentOrganization(...)`
- `SecondWorldEngine.getDepartmentRecruitmentNeeds()`
- `SecondWorldEngine.getPromotionCandidates(...)`
- `ResidentContext.career`
- `WorldSimulationContext.residentCareerSnapshot`

## Direct dependencies
- Company Organization.
- Resident Runtime.
- Resident config.
- World Clock for existing runtime state context.

## Consumers
- Resident Detail.
- Dialogue Runtime.
- Story Runtime.
- Dynamic Event Runtime.
- Quest Runtime.
- Second World Engine.
- Future office economy and AI decision modules.

## Save fields
- `residentRuntime.states[].career`
- `residentRuntime.states[].organization`
- `residentRuntime.organizationMutationHistory`
- `residentRuntime.processedOrganizationMutationIds`
- Career state is derived from resident config/default rules when no runtime state exists.
- Mutable career events are persisted through existing World Save resident runtime state, not raw config.

## Invariants
- Missing career fields must produce safe defaults.
- No new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type.
- Career conditions are optional and cannot break existing dialogue, story, event, or quest content.
- World Tick order is unchanged.
- Resident detail UI remains inside the existing Office Hub.
- Player career runtime remains separate from resident career lifecycle.
- Career events that affect assignment must use the unified organization mutation path.
- Assignment mutation must be all-or-nothing and idempotent by `sourceId`.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/widgets/resident_detail_dialog_test.dart`

## Known limitations
- Recruitment and promotion are queryable runtime recommendations. Applying career events now rewrites runtime organization assignment through the unified mutation path when the event carries a target role.
- No new career content JSON was added.

## Review Status

REVIEWED - PASS WITH DEBT

Latest validation: format PASS, analyze PASS, flutter test PASS with 98 tests, release build PASS, git diff --check PASS.
