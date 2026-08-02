# Story Module Manifest

## Purpose

Resolve, trigger, finish, and record resident stories from runtime context.

## Main files

- `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/resident_story_engine.dart`
- `fishing_office_flutter/lib/models/resident_story_config.dart`

## Data files

- `fishing_office_flutter/assets/config/resident_story.json`
- `fishing_office_flutter/assets/config/story.json`

## Public interfaces

- `getAvailableStories(residentId)`
- `triggerStory(residentId)`
- `finishStory(storyId)`
- `hasFinishedStory(storyId)`
- `loadFinishedStoryIds(ids)`

## Dependencies

- Resident
- Location
- Personality
- Dialogue
- Memory
- Relationship
- World Clock
- Weather
- Festival
- Rumor

## Consumers

- Second World
- Dynamic Event
- Quest
- Achievement
- Save

## Save fields

- `finishedStories`
- resident memory tags with `story:<id>`

## Invariants

- Non-repeatable stories must not repeat.
- General stories should remain available unless explicit conditions exclude them.
- Story completion can update memory, relationship, dialogue, and mood through existing APIs.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
