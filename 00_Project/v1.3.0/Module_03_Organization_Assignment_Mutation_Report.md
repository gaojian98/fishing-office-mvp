# Module 03 Organization Assignment Runtime Mutation Report

## Status

IMPLEMENTED – WAITING FOR REVIEW

## Scope

Implemented transactional organization assignment mutation for resident career lifecycle events without adding a top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type.

## Modified Modules

- Company Organization model
- Resident Career model
- Resident Runtime
- SecondWorldEngine facade
- World Save runtime state
- Framework smoke tests
- v1.3.0 project docs and manifests

## Runtime Rules

- Same-team promotion changes position and career level while preserving department and team.
- Cross-team promotion changes team and position, and derives department from target team when department is not explicitly supplied.
- Cross-department transfer changes department, team, and position.
- Demotion changes position and synchronizes department/team if target belongs elsewhere.
- Resignation marks the current organization assignment inactive, preserves resident and history, and sets employment status to resigned.
- Hire requires valid company, department, team, and position and reactivates assignment.

## Transaction And Idempotency

- Mutation validates company, department, team, position, capacity, reporting target, resident status, and management cycle before writing.
- Failed mutation leaves organization, career, and history unchanged.
- `sourceId` is the idempotency key.
- Repeated `sourceId` returns idempotent success without duplicate career or organization history.

## Save Compatibility

- Added runtime save fields:
  - `residentRuntime.states[].organization`
  - `residentRuntime.organizationMutationHistory`
  - `residentRuntime.processedOrganizationMutationIds`
- Old saves without these fields fall back to resident config/default organization.
- Raw JSON config is not rewritten.

## Performance

- Organization changes execute only when explicit career/organization mutation occurs.
- Regular Tick path does not scan all resident pairs.
- 100 resident current-state batch check is covered in smoke test and kept under the 300 ms guard.

## Test Coverage

Covered in `fishing_office_flutter/test/framework_smoke_test.dart`:

- same-team promotion
- cross-team promotion
- cross-department promotion
- cross-department transfer
- demotion
- hire
- resignation
- missing target position
- full target position
- invalid team ownership
- management cycle
- duplicate sourceId
- duplicate sourceId after save/restore
- failed mutation rollback
- old position release
- new position occupancy
- save/restore
- old save fallback
- 100 resident batch state validation

## Validation

- Targeted `flutter test test/framework_smoke_test.dart --name "organization assignment mutation"`: PASS.
- `dart format --set-exit-if-changed lib test`: PASS.
- `flutter analyze`: PASS.
- `flutter test`: PASS with 98 tests.
- `flutter test test/framework_smoke_test.dart`: PASS with 47 tests; full file runtime `67.42s`; internal performance gate PASS below 800ms.
- `flutter build web --release`: PASS.
- `git diff --check`: PASS.

## Known Limits

- Reporting graph validation prevents invalid/self report targets but does not yet model a complete multi-level reporting graph.
- Position capacity is inferred from current position hierarchy until product-provided capacity data exists.

## Recommendation

Proceed to product review after full validation passes.
