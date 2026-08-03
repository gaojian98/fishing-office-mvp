# ai_company_events

## Status

REVIEWED - COMMITTED

## Purpose

Coordinate large company events across organization, career, office economy, resident memory, company news, and company timeline without creating a new top-level runtime owner.

## Main files

- `fishing_office_flutter/lib/models/living_office_state.dart`
- `fishing_office_flutter/lib/models/world_save_data.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`

## Data files

- Runtime save state only.
- No new JSON type.

## Public interfaces

- `AICompanyEvent`
- `AICompanyEventResult`
- `SecondWorldEngine.triggerAICompanyEvent(...)`
- `SecondWorldEngine.getAICompanyEvents()`
- `WorldSaveManager.recordAICompanyEvent(...)`
- `WorldSaveManager.getAICompanyEvent(...)`
- `WorldSaveManager.aiCompanyEvents`

## Direct dependencies

- Organization Assignment Mutation
- Resident Career
- Office Economy
- Resident Long-Term Memory
- Company News & Timeline
- World Save

## Consumers

- Future AI decision execution flows
- Future company event UI projections
- Daily Summary
- Release and smoke validation

## Save fields

- `aiCompanyEvents`
- Existing `processedOfficeEventIds`
- Existing `officeEventCooldowns`
- `AICompanyEvent.reason`
- `AICompanyEvent.result`

## Invariants

- Company events are coordinators, not business state sources.
- Event side effects must call owning runtime interfaces.
- Organization changes use the unified Organization Mutation path.
- Economy changes use `settleOfficeEconomy(...)`.
- Resident memory uses `recordLongTermMemory(...)`.
- News and timeline are projections after successful domain effects.
- Stable `sourceId` prevents duplicate event execution.
- Resolved retries are idempotent successes; cancelled or expired retries are idempotent failures.
- Event records persist the reason and actual result separately from desired effects.
- Event history is bounded to 120 records.
- Old saves without `aiCompanyEvents` load an empty event history.
- World Tick order is unchanged.

## Relevant tests

- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations

- Event candidates are invoked through the existing `SecondWorldEngine` facade; automatic AI event harvesting from every runtime tick is deferred as P2 follow-up.
- AI decision execution is not directly injected into `SecondWorldEngine` because the current provider graph has `ResidentDecisionManager` depend on `SecondWorldEngine`.
- Event text uses engineering-level templates until product copy is provided.
