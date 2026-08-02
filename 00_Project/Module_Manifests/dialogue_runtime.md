# dialogue_runtime

## Purpose
Select resident dialogue and resident-action feedback from current runtime context.

## Main files
- `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart`
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart`
- `fishing_office_flutter/lib/core/engine/resident_dialogue_engine.dart`

## Data files
- `fishing_office_flutter/assets/config/resident_dialogue.json`
- `fishing_office_flutter/assets/config/office_dialog.json`

## Public interfaces
- `getDialogue(residentId)`
- `getAvailableDialogues(residentId)`
- `getInteractionFeedback(residentId, actionType, success: ...)`
- `loadServedNonRepeatableIds(ids)`

## Direct dependencies
- Resident, Location, Personality, Memory, Relationship, Friendship-compatible context, Clock, Weather, Festival, Rumor, Living Office, Player Influence.

## Consumers
- Second World, Story, Dynamic Event, Save, Resident Detail interactions.

## Save fields
- `dialogueRuntimeState.servedNonRepeatableIds`

## Invariants
- Never return an empty dialogue.
- Fallback remains safe.
- UI must not evaluate conditions.
- Normal dialogue excludes action-specific `actionType` entries.
- Action feedback stays JSON-backed and is selected by existing Dialogue Runtime.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/content_integration_test.dart`

## Known limitations
- Dedicated dialogue runtime tests are still concentrated in smoke and content integration tests.
