# daily_simulation

## Purpose
Run once-per-day world updates and generate daily summary.

## Main files
- `fishing_office_flutter/lib/core/managers/daily_simulation_manager.dart`

## Data files
- Runtime state only.

## Public interfaces
- `runDailySimulation()`
- `getTodayWorldSummary()`
- `getDailyChanges()`
- `hasRunToday()`
- `DailyWorldSummary.livingOfficeState`

## Direct dependencies
- World Tick, World Clock, Festival, Weather, Rumor, Resident, Story, Living Office, Save.

## Consumers
- Quest, Relationship, Second World, UI summary consumers.

## Save fields
- `dailySimulationState`

## Invariants
- Must run at most once per day.
- Second launch on same day must not duplicate rewards or summaries.
- Daily summary includes Living Office state without issuing rewards.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Summary presentation remains separate from simulation.
