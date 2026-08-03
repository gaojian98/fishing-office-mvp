# v1.3.0 Known Limitations

## Status

DEVELOPMENT COMPLETE - READY FOR HUMAN RC REVIEW

## Limitations

- Position capacity is inferred from current position hierarchy until product-defined capacity fields exist.
- Office Economy settlement scheduling remains explicit; automatic day/week/month settlement orchestration is deferred.
- AI Decision is deterministic and explainable, not a network AI model.
- AI Decision execution records processed recommendations but does not directly mutate organization, career, economy, quest, achievement, or player asset state.
- AI Company Events are invoked through `SecondWorldEngine`; automatic candidate generation from every Tick is deferred.
- AI Company Events do not inject `ResidentDecisionManager` into `SecondWorldEngine` because the current provider graph already has AI Decision depend on the engine.
- Company News uses engineering-level text templates until product copy is provided.
- Long-term memory compression uses bounded retention, decay, expiry, and summaries; natural-language compression is deferred.
- Long-horizon simulation is covered by smoke tests rather than a standalone simulation command.

## Non-Limitations

- No v1.2.x release files are modified.
- No Railway configuration is modified.
- No homepage UI is modified.
- No new JSON type is introduced.
- No new top-level Manager, Engine, Repository, Runtime, Provider, or page is introduced.
