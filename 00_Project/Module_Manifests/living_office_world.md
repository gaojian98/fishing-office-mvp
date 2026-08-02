# living_office_world

## Purpose
Summarize the current office as one shared living world state built from existing runtimes.

## Main files
- `fishing_office_flutter/lib/models/living_office_state.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`
- `fishing_office_flutter/lib/core/managers/daily_simulation_manager.dart`

## Data files
- No new JSON type.
- Reads existing runtime/config context through World Tick, Weather, Festival, Resident, Relationship, Rumor, Dialogue, Story, Dynamic Event, Quest, Achievement, and Save.

## Public interfaces
- `SecondWorldEngine.getLivingOfficeState()`
- `SecondWorldEngine.buildLivingOfficeState(...)`
- `SecondWorldEngine.buildOfficeWorldHistoryEntry(state)`
- `WorldSaveManager.livingOfficeState`
- `WorldSaveManager.officeWorldHistory`
- `livingOfficeStateProvider`
- `officeWorldHistoryProvider`

## Direct dependencies
- World Clock
- World Tick
- Festival Runtime
- Weather Runtime
- Resident Runtime
- Relationship Runtime
- Rumor Runtime
- Dialogue Runtime
- Story Runtime
- Dynamic Event Runtime
- Quest Runtime
- Achievement Runtime
- World Save

## Consumers
- Dialogue Runtime
- Story Runtime
- Dynamic Event Runtime
- Daily Simulation
- Second World Engine
- Future UI world summary consumers

## Save fields
- `livingOfficeState`
- `officeWorldHistory`
- `lastLivingOfficeUpdate`
- `processedOfficeEventIds`
- `officeEventCooldowns`

## Invariants
- No standalone Living Office manager or engine.
- One Tick builds one shared `WorldSimulationContext`.
- Office mood, activity, productivity, social, and tension are derived from existing runtime state.
- UI must not assemble Living Office state directly.
- Legacy saves without Living Office fields must load safely.
- Office world history is bounded.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- No dedicated Living Office UI yet.
- Current dialogue/story scan is still concentrated in the smoke test and emits verbose debug logs.
- Office level formulas are conservative engineering heuristics until product tuning provides exact weights.
