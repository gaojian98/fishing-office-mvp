# resident_schedule

## Purpose
Normalize office life phases and fallback workday/weekend behavior.

## Main files
- `fishing_office_flutter/lib/models/office_life_schedule.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_life_manager.dart`

## Data files
- `fishing_office_flutter/assets/config/resident_schedule.json`
- `fishing_office_flutter/assets/config/resident_activity.json`

## Public interfaces
- `OfficeLifeSchedule.fromRaw()`
- `OfficeLifeSchedule.normalizePhase()`
- `OfficeLifeSchedule.nextBoundary()`
- resident state schedule fields

## Direct dependencies
- World Clock, Resident config.

## Consumers
- Resident Runtime, Resident Decision, Save.

## Save fields
- `schedulePhase`
- `lastScheduleChange`
- `nextScheduleChange`
- `nextChangeTime`

## Invariants
- Cross-midnight schedules must work.
- Base schedule has priority over minor deviations.
- Workday/weekend state must differ.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Current fallback activities are code-level compatibility text.
