# world_tick

## Purpose
Run world runtime stages in a deterministic order.

## Main files
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`

## Data files
- Runtime state from dependent modules.

## Public interfaces
- `tickMinute()`
- `tickHour()`
- `tickDay()`
- `tickWeek()`
- `tickMonth()`
- `runTick()`
- `WorldSimulationContext.livingOfficeState`

## Direct dependencies
- World Clock, Festival, Weather, Resident, Rumor, Fish, Economy, Relationship, Dynamic Event, Dialogue, Story, Quest, Achievement, Save.

## Consumers
- Daily Simulation
- Second World Engine

## Save fields
- Indirect through dependent modules.

## Invariants
- A stage runs at most once per Tick.
- Stage order must remain deterministic.
- Failed stages should be isolated.
- Relationship daily evolution runs on Day Tick, not ordinary Hour Tick.
- Living Office state is refreshed once per Tick after Relationship and before Dynamic Event, Dialogue, and Story.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Tick tests are still concentrated in the smoke test file.
