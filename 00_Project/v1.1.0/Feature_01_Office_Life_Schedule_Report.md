# Feature 01 Office Life Schedule Report

## Modified Modules

- `OfficeLifeSchedule` model added as a lightweight value object.
- `ResidentRuntimeManager` now resolves office-life fallback schedules for residents without complete schedule JSON.
- `ResidentDecisionManager` now treats schedule as a stable baseline and only applies reasonable deviations.
- `ResidentLifeManager` now exposes compatible schedule phase fields from configured schedules.
- `WorldSaveManager` now serializes resident schedule runtime fields.
- `framework_smoke_test.dart` includes Office Life Schedule 2.0 regression coverage.

No new top-level Manager, Engine, Repository, page, or JSON type was added.

## Schedule Rules

Supported phases:

- `morning`
- `commute`
- `work_start`
- `working`
- `coffee_break`
- `lunch`
- `afternoon_work`
- `overtime`
- `off_work`
- `evening`
- `home`
- `sleep`
- `weekend`
- `holiday`

Workday baseline:

- Morning preparation from home.
- Commute before work.
- Office start, morning work, coffee break, lunch, afternoon work.
- Overtime only when personality and mood allow it.
- Evening route, home, and cross-midnight sleep.

Weekend baseline:

- Later wake-up.
- Home, coffee shop, park, seaside, dock, shopping, friend visit, or route-based leisure.
- No normal work state.

Decision deviation rules:

- Major causes such as weather, festival, story completion, and long absence may override schedule.
- Daily route decisions do not override stable runtime state on every tick.
- Working residents avoid unreasonable outdoor deviations except during breaks.
- Friend meetings are biased toward lunch, off-work, evening, or weekend windows.

## Compatibility Strategy

- Existing JSON schedule names are normalized into the supported phase list.
- Sparse or missing resident schedules fall back to deterministic office-life phases.
- Existing interfaces remain available:
  - `getResidentCurrentLocation(id)`
  - `getResidentCurrentActivity(id)`
  - `getResidentCurrentMood(id)`
  - `getResidentsAtLocation(locationId)`
  - `getResidentCurrentState(id)`
- Extended fields are additive:
  - `schedulePhase`
  - `isWorking`
  - `isOnBreak`
  - `isOvertime`
  - `isWeekend`
  - `nextLocation`
  - `nextActivity`
  - `nextChangeTime`
  - `scheduleReason`
- v1.0.0 saves without these fields load safely and receive runtime defaults.

## Test Results

- `flutter test`: PASS
- Office Life Schedule 2.0 smoke coverage:
  - Workday working state.
  - Lunch and break state.
  - Busy resident overtime.
  - Tired resident reduced overtime.
  - Weekend differs from workday.
  - Cross-midnight sleep.
  - Tick-driven state transition.
  - 100 residents return complete state.
  - Old save data loads with default schedule fields.
  - New save data restores schedule fields.

## Performance Results

Local smoke baseline:

- 100-resident `getAllResidentCurrentStates()` batch: under 250 ms in test.
- No repeated JSON read was introduced.
- No new top-level runtime stage was introduced.
- Existing WorldTick order remains unchanged.

## Known Limits

- Weather and festival schedule changes reuse existing runtime hooks and are not yet surfaced through dedicated office-location content.
- Weekend activity variety is deterministic and route-based, not content-authored per resident.
- Existing hand-authored schedule JSON can override the fallback where present.

## Next Step

Recommended next feature: Feature 02 Office Locations Integration.

Focus:

- Normalize office location IDs.
- Map office rooms to resident jobs and activities.
- Keep homepage UI unchanged.
- Continue using existing runtime and provider flow.
