# world_clock

## Purpose
Provide the single source of world time, date, weekday, season, festival pointer, and weather pointer.

## Main files
- `fishing_office_flutter/lib/core/managers/world_clock_manager.dart`
- `fishing_office_flutter/lib/core/engine/world_clock.dart`
- `fishing_office_flutter/lib/core/engine/world_calendar.dart`

## Data files
- Save runtime state only.

## Public interfaces
- `now()`
- `today()`
- `hour()`
- `minute()`
- `weekday()`
- `season()`
- `festival()`
- `weather()`

## Direct dependencies
- None.

## Consumers
- World Tick, Weather, Festival, Resident, Fish, Quest, Daily Simulation, Save.

## Save fields
- `worldClock`
- `worldCalendar`

## Invariants
- Runtime modules must not call `DateTime.now()` for world logic.
- All world-time decisions must flow through `WorldClockManager`.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Real-time and accelerated-time modes are not separated in this manifest.
