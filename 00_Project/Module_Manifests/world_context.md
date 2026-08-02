# world_context

## Purpose
Represent the shared runtime snapshot used by Tick and interaction flows.

## Main files
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`

## Data files
- Runtime state only.

## Public interfaces
- `SecondWorldEngine.getResidentContext(id)`
- `SecondWorldEngine.interactWithResident(id)`
- Tick context result types in `world_tick_manager.dart`

## Direct dependencies
- World Clock, Festival, Weather, Resident, Location, Personality, Rumor, Fish, Economy, Relationship, Event, Quest, Achievement.

## Consumers
- Runtime modules
- UI facade calls

## Save fields
- Indirect through World Save.

## Invariants
- One Tick should build shared context once when possible.
- UI must not construct its own world context by reading multiple runtimes.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Context is represented through existing classes rather than one global model file.
