# Module 08 AI Company Events Report

## Status

IMPLEMENTED - WAITING FOR REVIEW

## Scope

- Added bounded AI company event state.
- Added save/restore compatibility for company event history.
- Added a `SecondWorldEngine` facade to trigger company events without adding a new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type.
- Connected successful event effects to existing organization mutation, career, office economy, resident long-term memory, company news, and company timeline paths.

## Modified Modules

- Living office state models
- World save data
- World save manager
- Second World Engine
- Framework smoke tests
- v1.3.0 documentation and index

## Event Model

`AICompanyEvent` records:

- `eventId`
- `sourceId`
- `type`
- `scope`
- `participants`
- `conditions`
- `effects`
- `startTime`
- `endTime`
- `status`
- `cooldown`
- `createdAt`
- `updatedAt`
- `errors`

## Runtime Coordination

Events use existing runtime owners:

- Organization changes call Organization Mutation.
- Career changes call Career Runtime when provided as a standalone career effect.
- Office economy changes call Office Economy settlement.
- Resident memory changes call Long-Term Memory.
- Company news and timeline are generated only after successful effects.

## Idempotency

- `sourceId` is the stable event idempotency key.
- Processed events are also recorded through existing `processedOfficeEventIds`.
- Repeating the same event returns an idempotent result and does not duplicate timeline, news, memory, or economy entries.

## Transaction Handling

- Identity, cooldown, participant, condition, organization target, and economy target validation run before event state is finalized.
- Failed organization mutation returns failure before event news/timeline are written.
- Invalid event targets do not create successful timeline projections.

## Save Compatibility

- `WorldSaveData` includes `aiCompanyEvents`.
- Old saves without this field fall back to an empty list.
- Event history is bounded to 120 records.

## Performance

- Event lookup uses bounded saved event history and existing processed event sets.
- No routine Tick path or O(n²) resident comparison was introduced.
- World Tick order was not changed.

## Tests

Added smoke coverage for:

- Successful company event coordination.
- Organization mutation through existing mutation path.
- Office economy settlement through existing economy runtime.
- Long-term resident memory recording.
- Company timeline and news projection.
- Duplicate `sourceId` idempotency.
- Invalid organization target failure without timeline projection.
- Bounded event history.
- Save/restore and old-save fallback.

## Known Limitations

- Automatic company event candidate generation is not implemented in this module.
- Direct AI Decision Runtime execution is not injected into `SecondWorldEngine` to avoid introducing a provider cycle.
- Event copy is template-level and should be replaced when product content is supplied.

## Recommendation

Proceed to human review for Module 08 after full validation passes.
