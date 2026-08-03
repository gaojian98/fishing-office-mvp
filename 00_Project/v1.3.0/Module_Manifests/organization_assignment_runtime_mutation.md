# organization_assignment_runtime_mutation

## Status

IMPLEMENTED - REVIEW P1 FIXED - READY FOR COMMIT AUTHORIZATION

Current worktree note: Module 03 implementation is present locally and ready for commit authorization after review P1 resolution. It is not committed, pushed, merged, released, or deployed by this task.

## Goal

Establish one organization assignment mutation capability so Career Growth, future AI Decision, Economy, and Events cannot directly and separately modify resident organization assignment.

## Non-goals

- Company economy
- Salary settlement
- AI autonomous decisions
- Company news
- Timeline UI
- Homepage redesign
- New JSON content
- New top-level Manager, Engine, Repository, Runtime, Provider, or page

## Dependencies

- Company Organization
- Resident Career
- Resident Runtime
- World Save
- SecondWorldEngine facade
- Long-Term World Evolution Design
- Architecture Guardrails

## Input

- residentId
- mutationType
- target companyId / departmentId / teamId / positionId
- reason
- effectiveDate
- sourceId or mutationId
- optional reporting target

## Output

- updated current organization assignment
- persisted reportsToResidentId current reporting assignment
- updated career state when applicable
- mutation result
- mutation history record
- idempotency record
- save-compatible runtime state

## Mutation Types

- assign / hire
- promote
- transfer
- demote
- release position
- resign

## Validation Rules

- company exists
- department exists and belongs to company
- team exists and belongs to department
- position exists
- target position capacity allows assignment
- reporting target is valid
- multi-level reporting chain does not create a management cycle
- resident state allows the operation

## Transaction Rules

- all validation must complete before writes
- old position release and target position occupancy are one transaction
- failed mutation leaves career, organization, and history unchanged
- one resident cannot hold multiple active positions
- one limited-capacity position cannot be illegally occupied by multiple residents

## Idempotency Rules

- sourceId / mutationId is the idempotency key
- repeated mutation does not duplicate current state
- repeated mutation does not duplicate history
- retry after save/restore must be safe

## Save Compatibility

- new fields require defaults
- old save files must restore safely
- current state and mutation history remain separate
- raw resident JSON must not be rewritten

## World Tick Impact

- do not change existing Tick order
- mutation runs only on explicit career, organization, AI, economy, or event trigger
- regular Tick must not scan all resident pairs

## Performance Boundary

- 100 residents must remain stable
- common queries should use resident/team/department indexing or bounded scans
- no O(n²) routine Tick path

## UI Impact

- no homepage change
- no new page
- Resident Detail can read resulting organization state through existing projection only

## Test Scope

- same-team promotion
- cross-team promotion
- cross-department transfer
- demotion
- hire
- resignation
- missing target position
- full target position
- invalid team ownership
- management cycle
- duplicate mutationId
- transaction rollback
- save/restore
- old-save fallback
- 100-resident validation

## Known Risks

- Position capacity is inferred from existing position hierarchy and may need product-defined data later.
- Module 03 must be reviewed before Office Economy or AI Decision consumes mutation outcomes.

## Acceptance Criteria

- Formal implementation is ready for review on the agreed v1.3 branch.
- `git diff --check` passes.
- Targeted and full Flutter validation pass.
- No v1.2.0 release or Railway production files are modified.

## Forbidden Changes

- no v1.2.0 Tag or Release modification
- no Railway production modification
- no UI redesign
- no new top-level architecture owner
- no direct Career Runtime field patch bypassing Organization Mutation

## Readiness Review

Module 01 and Module 02 are REVIEWED - COMMITTED. Module 03 is IMPLEMENTED - REVIEW P1 FIXED - READY FOR COMMIT AUTHORIZATION and must be committed or explicitly accepted before Office Economy.
