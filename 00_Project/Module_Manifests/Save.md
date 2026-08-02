# Save Module Manifest

## Purpose

Persist and restore runtime state without saving raw config data.

## Main files

- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/repository/world_save_repository.dart`
- `fishing_office_flutter/lib/models/world_save_data.dart`

## Data files

- No content JSON. Uses local save repository state.

## Public interfaces

- `saveWorld()`
- `loadWorld()`
- `resetWorld()`
- `autoSave()`
- runtime state setters
- `recordInteraction()`

## Dependencies

- World Clock
- Festival
- Weather
- Rumor
- Resident
- Memory
- Relationship
- Story
- Dialogue

## Consumers

- Second World Engine
- World Tick
- Daily Simulation
- Quest
- Economy
- Relationship
- Achievement
- Dynamic Event

## Save fields

- `worldClock`
- `worldCalendar`
- `festivalRuntime`
- `weatherRuntime`
- `rumorRuntime`
- `residentRuntime`
- `residentMemory`
- `residentRelationship`
- `finishedStories`
- `dialogueRuntimeState`
- `dailySimulationState`
- `questRuntimeState`
- `economyRuntimeState`
- `relationshipRuntimeState`
- `achievementRuntimeState`
- `dynamicEventRuntimeState`
- `taskRewards`
- `interactionHistory`

## Invariants

- Save runtime data only, not original JSON config.
- Same payload should not be repeatedly saved.
- Old v1.0.0 saves must safely load or fallback.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
