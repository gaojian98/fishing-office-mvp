# save_system

## Purpose
Persist runtime state and restore it safely.

## Main files
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/models/world_save_data.dart`
- `fishing_office_flutter/lib/core/repository/world_save_repository.dart`

## Data files
- Runtime save state only.

## Public interfaces
- `saveWorld()`
- `loadWorld()`
- `resetWorld()`
- `autoSave()`
- runtime state setters
- `recordInteraction()`

## Direct dependencies
- Clock, Festival, Weather, Rumor, Resident, Memory, Relationship, Story, Dialogue.

## Consumers
- Second World, World Tick, Daily Simulation, Quest, Economy, Relationship, Achievement, Dynamic Event.

## Save fields
- `worldClock`, `worldCalendar`, `festivalRuntime`, `weatherRuntime`, `rumorRuntime`, `residentRuntime`, `residentMemory`, `residentRelationship`, `finishedStories`, `dialogueRuntimeState`, `dailySimulationState`, `questRuntimeState`, `economyRuntimeState`, `relationshipRuntimeState`, `achievementRuntimeState`, `dynamicEventRuntimeState`, `taskRewards`, `interactionHistory`.

## Invariants
- Save runtime data, not raw config.
- Same payload should not be repeatedly saved.
- v1.0.0 saves must safely load or fallback.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Save repository is local/mock in current scope.
