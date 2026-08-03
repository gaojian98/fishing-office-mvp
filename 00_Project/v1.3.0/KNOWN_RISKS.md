# v1.3.0 Known Risks

## Module 03 Organization Assignment Runtime Mutation

Status: REVIEWED - COMMITTED

## Module 04 Office Economy

Status: IMPLEMENTED - COMMITTED

## Module 05 AI Decision System

Status: IMPLEMENTED - WAITING FOR REVIEW

## Current Risks

- Position capacity is inferred from existing position hierarchy until product-defined capacity fields exist.
- Office Economy settlement is explicit runtime API driven; automatic daily / weekly / monthly settlement scheduling is deferred.
- Office Economy budget allocation uses current active resident assignment and salary state because no product-provided company budget JSON exists yet.
- AI Decision scoring is deterministic and explainable. It is not a network AI model.
- AI Decision execution records that a recommendation was processed; it does not execute organization, career, economy, quest, achievement, or player asset mutations.
- Future Company Event modules must call the owning runtime interfaces when translating AI recommendations into state changes.

## Not Risks In This Task

- v1.2.0 release files are not modified.
- Railway configuration is not modified.
- Homepage UI is not modified.
- No new JSON type is introduced.
