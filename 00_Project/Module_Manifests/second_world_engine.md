# second_world_engine

## Purpose
Provide the unified facade for world and resident interactions.

## Main files
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`

## Data files
- Uses existing config/runtime state through dependencies.

## Public interfaces
- `loadWorld()`
- `startWorld()`
- `saveWorld()`
- `getResidentContext(id)`
- `interactWithResident(id)`
- `selectFairyEvent(service)`
- `triggerFairyEvent(service)`
- `getLivingOfficeState()`
- `buildLivingOfficeState(...)`
- `buildOfficeWorldHistoryEntry(state)`

## Direct dependencies
- Resident, Location, Personality, Memory, Relationship, Dialogue, Story, Festival, Weather, Rumor, Office Group, Living Office, Save.

## Consumers
- UI, resident interaction flows, Dynamic Event, Fish, Quest, Achievement.

## Save fields
- Indirect through World Save.

## Invariants
- UI calls this facade for resident interactions.
- UI must not call multiple resident runtimes directly.
- `InteractionResult` remains backward compatible.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- No UI resident map is present.
- Living Office state is exposed for future UI summary use but does not add a page.
