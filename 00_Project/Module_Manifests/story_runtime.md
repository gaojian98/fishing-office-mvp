# story_runtime

## Purpose
Filter, trigger, finish, record, and expose resident stories with product-facing public hints.

## Main files
- `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart`
- `fishing_office_flutter/lib/models/resident_story_config.dart`
- `fishing_office_flutter/lib/core/engine/resident_story_engine.dart`

## Data files
- `fishing_office_flutter/assets/config/resident_story.json`
- `fishing_office_flutter/assets/config/story.json`

## Public interfaces
- `getAvailableStories(residentId)`
- `triggerStory(residentId)`
- `finishStory(storyId)`
- `hasFinishedStory(storyId)`
- `loadFinishedStoryIds(ids)`

## Direct dependencies
- Dialogue, Resident, Memory, Relationship, Weather, Festival, Rumor, Living Office, Player Influence.

## Consumers
- Second World, Dynamic Event, Quest, Achievement, Save, Resident Detail.

## Save fields
- `finishedStories`
- memory tags `story:<id>`

## Invariants
- Non-repeatable stories must not repeat.
- General stories remain available unless explicit conditions exclude them.
- Trust and friendship thresholds must be treated as gates, not rewards.
- UI-visible hints must not expose internal condition keys.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/content_integration_test.dart`

## Known limitations
- No dedicated story test directory yet.
