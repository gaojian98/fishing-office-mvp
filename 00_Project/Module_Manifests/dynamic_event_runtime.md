# dynamic_event_runtime

## Purpose
Filter, trigger, resolve, expire, and persist dynamic world events, including office, social, weather, festival, fishing, and mystery content.

## Main files
- `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart`
- `fishing_office_flutter/lib/core/services/fairy_event_service.dart`
- `fishing_office_flutter/lib/models/dynamic_event_config.dart`

## Data files
- `fishing_office_flutter/assets/config/events.json`
- `fishing_office_flutter/assets/config/event.json` mirrors the same event content for legacy compatibility.

## Public interfaces
- `getAvailableEvents()`
- `getActiveEvents()`
- `triggerEvent(eventId)`
- `resolveEvent(eventId, choice)`
- `expireEvent(eventId)`
- `getEventContext()`
- `hasTriggered(eventId)`

## Direct dependencies
- Clock, Daily Simulation, Resident, Personality, Decision, Relationship, Dialogue, Story, Festival, Weather, Rumor, Fish, Quest, Achievement, Save.

## Consumers
- Fishing wait flow, Fairy Event Service, Second World, World Tick, Office Hub event projection.

## Save fields
- `dynamicEventRuntimeState`

## Invariants
- Cooldowns and non-repeatable rules must hold.
- Event results must use existing runtime APIs.
- UI must not read `events.json` directly.
- Event choices must carry product-facing text and runtime-settled result payloads.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/content_integration_test.dart`

## Known limitations
- Event tests are still concentrated in smoke and content integration tests.
