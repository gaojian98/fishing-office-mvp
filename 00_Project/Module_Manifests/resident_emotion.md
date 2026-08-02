# resident_emotion

## Purpose
Normalize and stabilize resident mood changes.

## Main files
- `fishing_office_flutter/lib/core/utils/resident_mood.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/resident_memory_engine.dart`

## Data files
- Resident mood fields in config and save state.

## Public interfaces
- `normalizeResidentMood()`
- `applyEmotionOverride()`
- `recordEmotionChange()`

## Direct dependencies
- Resident Runtime, Memory, Weather, Festival, Story.

## Consumers
- Dialogue, Story, Resident Decision, Save.

## Save fields
- resident runtime `mood`
- memory `emotionHistory`

## Invariants
- Mood must not jitter every Tick.
- Minor changes respect minimum duration.
- Major events may override immediately.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- No separate emotion runtime exists by design.
