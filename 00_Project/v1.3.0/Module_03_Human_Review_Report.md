# Module 03 Human Review Report

## Status

PASS - P1 FIXED - REVIEW CLOSED

## Scope

- Organization Mutation constraints
- Career Runtime organization write path
- Transaction rollback
- Idempotency
- Save / Restore compatibility
- Reporting Graph references
- Runtime query duplication
- Module 04 technical debt
- ADR / DESIGN_DECISIONS consistency
- Test coverage

## Validation

- `flutter analyze`: PASS
- `flutter test`: PASS, 98 tests
- `flutter build web --release`: PASS
- `git diff --check`: PASS

## Findings

### M03-HR-001 Reporting graph is not fully persisted or cycle-checked

Severity: P1 - FIXED

Module: Organization Assignment Mutation

Description:
Organization Mutation accepts `targetReportsToResidentId` and validates self-reference plus target resident validity, but current `OrganizationAssignment` does not persist the reporting target as part of current assignment state. Mutation records store `targetReportsToResidentId`, but runtime current organization state cannot represent the resulting reporting graph.

Impact:
- Cross-level reporting relationships are not actually updated as current state.
- Multi-level management cycles cannot be detected because no current reporting graph exists.
- Future Office Economy / AI Decision / Organization Timeline modules would need to infer reporting from history, which conflicts with current-state/read-model expectations.

Evidence:
- `OrganizationMutationRecord` stores `targetReportsToResidentId`.
- `OrganizationAssignment` stores company, department, team, position, tags, and active state only.
- `_validateOrganizationMutation` checks `reportsToResidentId == residentId` and target validity, but does not traverse an existing reporting graph.
- Smoke test covers self-cycle only, not A -> B -> C -> A cycle.

Expected:
Mutation should either persist current reporting assignment in the current organization state or explicitly defer reporting graph mutation behind a documented accepted decision. If reporting graph remains deferred, Module 03 should not claim full management-cycle prevention.

Actual after fix:
Current `OrganizationAssignment` persists `reportsToResidentId`; mutation validation traverses the reporting chain and rejects multi-level management cycles.

Resolution:
Current reporting assignment support and multi-level cycle checks were added through the existing organization mutation path. `DD-006` and `ADR-022` document the accepted current-state reporting graph rule.

## Non-Blocking Observations

- Transaction rollback is acceptable for the current in-memory write path: all validation runs before state maps/history/id sets are mutated.
- Idempotency is acceptable for stable `sourceId`; repeated mutations do not duplicate state or history and survive save/restore.
- Career Runtime organization-changing events route through `assignResident`, but the later optional career stat update can still append a second career event when extra salary/performance/tag fields are supplied. This does not directly patch organization fields, but should remain watched.
- Save/Restore stores mutation history and processed source ids separately from current runtime states and falls back safely when old saves lack these fields.
- Capacity rules remain inferred from position hierarchy, consistent with `DD-004`.
- Long-term mutation history is append-only; `ADR-016` requires a future retention/summary strategy.

## Review Decision

`M03-HR-001` is fixed in the working tree. Module 03 can proceed to commit authorization because full validation remains PASS.
