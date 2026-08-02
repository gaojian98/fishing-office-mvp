# Second World Module Manifest

## Purpose

Provide the unified resident/world interaction facade for UI and gameplay.

## Main files

- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`

## Data files

- Uses existing runtime and config state through dependencies.

## Public interfaces

- `loadWorld()`
- `startWorld()`
- `saveWorld()`
- `getResidentContext(id)`
- `interactWithResident(id)`
- `selectFairyEvent(service)`
- `triggerFairyEvent(service)`

## Dependencies

- Resident
- Location
- Personality
- Memory
- Relationship
- Dialogue
- Story
- Festival
- Weather
- Rumor
- Save

## Consumers

- UI
- Resident interactions
- Dynamic Event
- Fish Runtime
- Quest
- Achievement

## Save fields

- Indirect through World Save.

## Invariants

- UI should call this facade for resident interactions.
- UI must not call multiple Resident runtimes directly.
- InteractionResult must remain backward compatible.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
