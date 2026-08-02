# memory_runtime

## Purpose
Record resident memory, interaction tags, emotion history, and story markers.

## Main files
- `fishing_office_flutter/lib/core/engine/resident_memory_engine.dart`
- `fishing_office_flutter/lib/models/resident_memory_config.dart`

## Data files
- `fishing_office_flutter/assets/config/resident_memory.json`

## Public interfaces
- `getResidentMemory(id)`
- `recordInteraction(id, type)`
- `recordEmotionChange(id, ...)`
- `load(config)`
- `toConfig()`

## Direct dependencies
- World Clock utility time.

## Consumers
- Relationship, Dialogue, Story, Dynamic Event, Second World, Save.

## Save fields
- `residentMemory`
- `interactionHistory`

## Invariants
- Memory is story history, not economy history.
- Important emotional changes should not duplicate too frequently.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- No memory UI in current scope.
