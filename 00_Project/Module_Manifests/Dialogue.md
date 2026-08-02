# Dialogue Module Manifest

## Purpose

Select resident dialogue from runtime context.

## Main files

- `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/resident_dialogue_engine.dart`
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart`

## Data files

- `fishing_office_flutter/assets/config/resident_dialogue.json`
- `fishing_office_flutter/assets/config/office_dialog.json`

## Public interfaces

- `getDialogue(residentId)`
- `getAvailableDialogues(residentId)`
- `loadServedNonRepeatableIds(ids)`

## Dependencies

- Resident
- Location
- Personality
- Memory
- Relationship
- World Clock
- Weather
- Festival
- Rumor

## Consumers

- Second World
- Story
- Dynamic Event
- Quest
- Save

## Save fields

- `dialogueRuntimeState.servedNonRepeatableIds`

## Invariants

- Never return an empty dialogue; fallback must remain safe.
- UI must not evaluate dialogue conditions.
- Non-repeatable dialogue IDs must persist.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
