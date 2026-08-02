# Location Module Manifest

## Purpose

Normalize office and world locations into a shared context used by resident, dialogue, story, event, quest, and save logic.

## Main files

- `fishing_office_flutter/lib/models/location_context.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`

## Data files

- Existing resident and schedule location fields.

## Public interfaces

- `LocationContext.normalizeId(raw)`
- `LocationContext.fromId(id)`
- `LocationContext.isReasonableForPhase(locationId, phase)`
- `getResidentLocationContext(id)`
- `getLocationContext(locationId)`
- `getResidentsByLocationType(type)`

## Dependencies

- Resident
- World Clock

## Consumers

- Resident
- Dialogue
- Story
- Dynamic Event
- Quest
- Second World
- Save

## Save fields

- `residentCurrentLocation`
- `locationVisitHistory`

## Invariants

- 1080x1920 UI coordinates are unrelated to location logic.
- Legacy location aliases must normalize without rewriting JSON.
- Capacity fallback must be deterministic.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
