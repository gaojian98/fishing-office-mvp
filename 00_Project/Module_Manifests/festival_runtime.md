# festival_runtime

## Purpose
Resolve active festivals and festival tags.

## Main files
- `fishing_office_flutter/lib/core/managers/festival_runtime_manager.dart`
- `fishing_office_flutter/lib/models/festival_config.dart`
- `fishing_office_flutter/lib/core/repository/festival_repository.dart`

## Data files
- `fishing_office_flutter/assets/config/festival.json`

## Public interfaces
- `getTodayFestival()`
- `getActiveFestivals()`
- `isFestivalActive(festivalId)`
- `getFestivalTags()`
- `residentFestivalContext(residentId)`
- `applyFestivalContext(context)`

## Direct dependencies
- World Clock, Resident.

## Consumers
- Resident, Dialogue, Story, Rumor, Fish, Economy, Dynamic Event, Daily Simulation.

## Save fields
- `festivalRuntime`

## Invariants
- Festivals add context; they must not force all residents to one location.
- UI should not read festival JSON directly.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Festival decorations are separate from runtime.
