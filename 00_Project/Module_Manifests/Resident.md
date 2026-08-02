# Resident Module Manifest

## Purpose

Resolve resident life state, schedule phase, decisions, mood, activity, and current location.

## Main files

- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_life_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_decision_manager.dart`
- `fishing_office_flutter/lib/models/resident_config.dart`
- `fishing_office_flutter/lib/models/resident_life_config.dart`
- `fishing_office_flutter/lib/models/office_life_schedule.dart`

## Data files

- `fishing_office_flutter/assets/config/residents.json`
- `fishing_office_flutter/assets/config/resident.json`
- `fishing_office_flutter/assets/config/resident_schedule.json`
- `fishing_office_flutter/assets/config/resident_activity.json`

## Public interfaces

- `getResidentCurrentState(id)`
- `getResidentCurrentLocation(id)`
- `getResidentCurrentActivity(id)`
- `getResidentCurrentMood(id)`
- `getAllResidentCurrentStates()`
- `applyRuntimeOverride()`
- `loadRuntimeStates()`

## Dependencies

- World Clock
- Location
- Personality
- Weather
- Festival
- Rumor
- Story
- Memory

## Consumers

- Second World Engine
- Dialogue
- Story
- Rumor
- Relationship
- Dynamic Event
- Quest
- Achievement
- Save

## Save fields

- `residentRuntime.states`
- `residentCurrentLocation`
- `schedulePhase`
- `temporaryLocationOverride`
- `overrideReason`
- `overrideExpiresAt`
- `lastScheduleChange`
- `nextScheduleChange`

## Invariants

- Resident state must be non-empty for enabled residents.
- Schedule phase must remain compatible with location.
- Base schedule has priority over personality and minor random behavior.
- No high-frequency location or mood jitter.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
