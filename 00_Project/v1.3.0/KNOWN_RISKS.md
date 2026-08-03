# v1.3.0 Known Risks

## Module 03 Organization Assignment Runtime Mutation

Status: REVIEWED - COMMITTED

## Module 04 Office Economy

Status: IMPLEMENTED - WAITING FOR REVIEW

## Current Risks

- Position capacity is inferred from existing position hierarchy until product-defined capacity fields exist.
- Office Economy settlement is explicit runtime API driven; automatic daily / weekly / monthly settlement scheduling is deferred.
- Office Economy budget allocation uses current active resident assignment and salary state because no product-provided company budget JSON exists yet.
- Module 04 must be reviewed before AI Decision depends on economy outcomes.

## Not Risks In This Task

- v1.2.0 release files are not modified.
- Railway configuration is not modified.
- Homepage UI is not modified.
- No new JSON type is introduced.
