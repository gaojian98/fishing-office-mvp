# v1.3.0 Known Risks

## Module 03 Organization Assignment Runtime Mutation

Status: REVIEWED - COMMITTED

## Module 04 Office Economy

Status: IMPLEMENTED - COMMITTED

## Module 05 AI Decision System

Status: IMPLEMENTED - COMMITTED

## Module 06 Long-Term Memory

Status: IMPLEMENTED - COMMITTED

## Module 07 Company News & Timeline

Status: IMPLEMENTED - COMMITTED

## Module 08 AI Company Events

Status: REVIEWED - COMMITTED

## Current Risks

- Position capacity is inferred from existing position hierarchy until product-defined capacity fields exist.
- Office Economy settlement is explicit runtime API driven; automatic daily / weekly / monthly settlement scheduling is deferred.
- Office Economy budget allocation uses current active resident assignment and salary state because no product-provided company budget JSON exists yet.
- AI Decision scoring is deterministic and explainable. It is not a network AI model.
- AI Decision execution records that a recommendation was processed; it does not execute organization, career, economy, quest, achievement, or player asset mutations.
- Future Company Event modules must call the owning runtime interfaces when translating AI recommendations into state changes.
- Long-term memory compression is currently implemented as expiry, decay, bounded retention, and summary APIs, not natural-language summarization.
- Long-term memory has no UI in this module.
- Company Timeline currently records explicit projection calls; automatic harvesting from all runtime mutation sources is deferred to AI Company Events.
- Company News uses engineering-level text templates until product copy is provided.
- AI Company Events currently expose explicit trigger coordination through `SecondWorldEngine`; automatic candidate generation from every Tick is deferred.
- AI Company Events do not directly inject `ResidentDecisionManager` into `SecondWorldEngine` because the current provider graph already has AI Decision depend on the engine.
- AI Company Events preserve failed or cancelled retry results as idempotent failures, not successful duplicate handling.

## Not Risks In This Task

- v1.2.0 release files are not modified.
- Railway configuration is not modified.
- Homepage UI is not modified.
- No new JSON type is introduced.
