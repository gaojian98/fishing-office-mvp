# Dynamic Event Module Manifest

## Purpose

Generate and resolve active world events from current runtime context.

## Main files

- `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart`
- `fishing_office_flutter/lib/core/services/fairy_event_service.dart`
- `fishing_office_flutter/lib/models/dynamic_event_config.dart`

## Data files

- `fishing_office_flutter/assets/config/events.json`

## Public interfaces

- `getAvailableEvents()`
- `getActiveEvents()`
- `triggerEvent(eventId)`
- `resolveEvent(eventId, choice)`
- `expireEvent(eventId)`
- `getEventContext()`
- `hasTriggered(eventId)`

## Dependencies

- World Clock
- Daily Simulation
- Resident
- Personality
- Resident Decision
- Relationship
- Dialogue
- Story
- Festival
- Weather
- Rumor
- Fish
- Quest
- Achievement
- Save

## Consumers

- Fishing waiting flow
- Fairy Event Service
- Second World Engine
- World Tick

## Save fields

- `dynamicEventRuntimeState.activeEvents`
- `dynamicEventRuntimeState.finishedEvents`
- `dynamicEventRuntimeState.expiredEvents`
- `dynamicEventRuntimeState.cooldowns`
- `dynamicEventRuntimeState.choices`
- `dynamicEventRuntimeState.triggerHistory`

## Invariants

- Non-repeatable events must not repeat.
- Cooldowns must be respected.
- Event result application must use existing runtime APIs.
- Pages must not read `events.json` directly.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
