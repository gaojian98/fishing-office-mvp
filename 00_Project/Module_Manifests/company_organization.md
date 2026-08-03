# company_organization

## Purpose
Provide the default company, department, team, and position structure for residents and future office systems.

## Main files
- `fishing_office_flutter/lib/models/company_organization.dart`
- `fishing_office_flutter/lib/models/resident_config.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`

## Data files
- Existing resident config fields.
- Optional future resident fields: `organization`, `companyId`, `departmentId`, `teamId`, `positionId`, `organizationTags`.

## Public interfaces
- `ResidentProfile.organization`
- `ResidentCurrentState.organization`
- `OrganizationAssignment.active`
- `OrganizationMutationRequest`
- `OrganizationMutationResult`
- `OrganizationMutationRecord`
- `ResidentRuntimeManager.companyOrganization`
- `ResidentRuntimeManager.getResidentOrganization(id)`
- `ResidentRuntimeManager.getResidentOrganizationContext(id)`
- `ResidentRuntimeManager.getResidentsByDepartment(departmentId)`
- `ResidentRuntimeManager.getResidentsByTeam(teamId)`
- `ResidentRuntimeManager.assignResident(...)`
- `ResidentRuntimeManager.promoteResident(...)`
- `ResidentRuntimeManager.transferResident(...)`
- `ResidentRuntimeManager.demoteResident(...)`
- `ResidentRuntimeManager.releasePosition(...)`
- `ResidentRuntimeManager.resignResident(...)`
- `SecondWorldEngine.getCompanyOrganization()`
- `SecondWorldEngine.getResidentOrganizationContext(id)`
- `SecondWorldEngine.assignResidentOrganization(...)`
- `SecondWorldEngine.resignResidentOrganization(...)`
- `ResidentContext.organization`
- `WorldSimulationContext.organizationSnapshot`

## Direct dependencies
- Resident config.
- Resident Runtime.
- Second World Engine.

## Consumers
- Dialogue Runtime.
- Story Runtime.
- Quest Runtime.
- Dynamic Event Runtime.
- World Tick shared context.
- Future career, AI decision, and economy modules.

## Save fields
- `residentRuntime.states[].organization`
- `residentRuntime.organizationMutationHistory`
- `residentRuntime.processedOrganizationMutationIds`
- Missing save fields fall back to resident config/default organization.

## Invariants
- No new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type.
- Existing resident JSON remains compatible when organization fields are absent.
- Default organization must always resolve a company, department, team, and position.
- Dialogue, Story, Quest, and Dynamic Event organization support is optional and non-breaking.
- World Tick order is unchanged.
- Organization mutation must validate target company, department, team, position, capacity, reporting target, resident status, and management cycle before writing.
- Organization mutation is transactional: failed mutation leaves existing career and organization state unchanged.
- `sourceId` is the idempotency key; repeated mutation source must not duplicate history.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Default resident organization is heuristic until product-provided company data is added to JSON.
- Department manager and team leader are represented by position metadata and assignment helpers, not by a reporting graph UI.
- Reporting graph validation currently prevents invalid/self reporting and inactive manager targets, but does not model a full multi-level org chart beyond the existing position hierarchy.

## Review Status

REVIEWED - PASS WITH DEBT

Latest validation: format PASS, analyze PASS, flutter test PASS with 98 tests, release build PASS, git diff --check PASS.
