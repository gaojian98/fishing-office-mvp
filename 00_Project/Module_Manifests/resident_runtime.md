# resident_runtime

## Purpose
Resolve resident current state and expose resident context helpers.

## Main files
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/models/resident_config.dart`
- `fishing_office_flutter/lib/models/resident_life_config.dart`

## Data files
- `fishing_office_flutter/assets/config/residents.json`
- `fishing_office_flutter/assets/config/resident.json`
- `fishing_office_flutter/assets/config/resident_schedule.json`
- `fishing_office_flutter/assets/config/resident_activity.json`

## Public interfaces
- `getResidentCurrentState(id)`
- `getAllResidentCurrentStates()`
- `getResidentLocationContext(id)`
- `getResidentPersonalityContext(id)`
- `applyRuntimeOverride()`
- `loadRuntimeStates()`

## Direct dependencies
- World Clock, Schedule, Location, Personality.

## Consumers
- Dialogue, Story, Rumor, Relationship, Dynamic Event, Quest, Achievement, Save, Second World.

## Save fields
- `residentRuntime.states`

## Invariants
- Enabled residents must return complete state.
- Location must be compatible with schedule phase.
- Runtime overrides must remain day-scoped.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Tests are not split into a dedicated resident test folder yet.
