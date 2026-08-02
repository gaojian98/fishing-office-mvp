# Festival Module Manifest

## Purpose

Resolve active festivals and expose festival context to residents, dialogue, stories, rumors, events, fish, and economy.

## Main files

- `fishing_office_flutter/lib/core/managers/festival_runtime_manager.dart`
- `fishing_office_flutter/lib/core/repository/festival_repository.dart`
- `fishing_office_flutter/lib/models/festival_config.dart`

## Data files

- `fishing_office_flutter/assets/config/festival.json`

## Public interfaces

- `getTodayFestival()`
- `getActiveFestivals()`
- `isFestivalActive(festivalId)`
- `getFestivalTags()`
- `applyFestivalContext(context)`
- `residentFestivalContext(residentId)`

## Dependencies

- World Clock
- Resident

## Consumers

- Resident
- Dialogue
- Story
- Rumor
- Fish
- Economy
- Dynamic Event
- Daily Simulation

## Save fields

- `festivalRuntime.activeFestivalIds`
- `festivalRuntime.tags`

## Invariants

- Festivals add context and tags; they should not force all residents to one place.
- UI should not read festival JSON directly.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
