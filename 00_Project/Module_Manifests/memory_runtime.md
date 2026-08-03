# memory_runtime

## Purpose
Record resident memory, interaction tags, emotion history, story markers, and bounded long-term memories.

## Main files
- `fishing_office_flutter/lib/core/engine/resident_memory_engine.dart`
- `fishing_office_flutter/lib/models/resident_memory_config.dart`

## Data files
- `fishing_office_flutter/assets/config/resident_memory.json`

## Public interfaces
- `getResidentMemory(id)`
- `recordInteraction(id, type)`
- `recordEmotionChange(id, ...)`
- `recordLongTermMemory(id, ...)`
- `compactLongTermMemories(...)`
- `getResidentMemorySummary(id)`
- `load(config)`
- `toConfig()`

## Direct dependencies
- World Clock utility time.

## Consumers
- Relationship, Dialogue, Story, Dynamic Event, Second World, Save.

## Save fields
- `residentMemory`
- `interactionHistory`
- `residentMemory.memories.longTermMemories`

## Invariants
- Memory is story history, not economy history.
- Important emotional changes should not duplicate too frequently.
- Long-term memory source IDs are idempotent per resident.
- Long-term memory history is bounded to 60 records per resident.
- Important memories are retained ahead of low-importance memories.
- Expired low-importance memories can be removed.
- AI Decision, Dialogue, and Story should consume summaries or memory tags rather than reimplementing memory rules.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- No memory UI in current scope.
- Dedicated long-term memory tests are not split out yet.
