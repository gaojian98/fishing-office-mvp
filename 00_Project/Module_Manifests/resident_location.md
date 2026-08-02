# resident_location

## Purpose
Normalize all resident locations into `LocationContext`.

## Main files
- `fishing_office_flutter/lib/models/location_context.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`

## Data files
- Existing location fields in resident and schedule config.

## Public interfaces
- `LocationContext.normalizeId(raw)`
- `LocationContext.fromId(id)`
- `LocationContext.isReasonableForPhase(locationId, phase)`
- `getResidentLocationContext(id)`
- `getLocationContext(locationId)`
- `getResidentsByLocationType(type)`

## Direct dependencies
- Resident Runtime.

## Consumers
- Dialogue, Story, Dynamic Event, Quest, Save, Second World.

## Save fields
- `residentCurrentLocation`
- `locationVisitHistory`

## Invariants
- Location aliases must normalize without rewriting JSON.
- Capacity fallback must be deterministic.
- Location cannot violate schedule phase.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Location display names are currently code-level.
