# player_influence

## Purpose
Represent player-to-office and office-to-player consequences as shared runtime context.

## Main files
- `fishing_office_flutter/lib/models/player_influence.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`

## Data files
- Runtime save only.
- No new JSON type.

## Public interfaces
- `SecondWorldEngine.getPlayerInfluenceContext()`
- `SecondWorldEngine.buildPlayerInfluenceContext(...)`
- `WorldSimulationContext.playerInfluenceContext`
- `WorldTickContext.playerInfluenceContext`
- `WorldSaveManager.playerInfluenceContext`
- `WorldSaveManager.playerOfficeInfluence`
- `WorldSaveManager.recentPlayerActions`
- `WorldSaveManager.officeReputation`
- `WorldSaveManager.setPlayerInfluenceContext(context)`
- `WorldSaveManager.recordPlayerAction(action)`

## Direct dependencies
- Living Office state
- Career state
- Player skill state
- Friendship state
- Interaction history
- Quest summary
- Achievement summary
- Rumor and dynamic event snapshots

## Consumers
- Dialogue Runtime
- Story Runtime
- Dynamic Event Runtime
- Quest Runtime
- Achievement Runtime
- Daily Simulation
- Second World Engine

## Save fields
- `playerInfluenceContext`
- `playerOfficeInfluence`
- `recentPlayerActions`
- `officeReputation`

## Invariants
- No standalone Player Influence manager, engine, repository, UI, or JSON type.
- Player reputation is resident-facing runtime context, not a title or ranking system.
- Player influence values are derived from existing runtime state and clamped to `0..100`.
- Office state changes influence event/dialogue/story weights and conditions, not forced outcomes.
- Old saves without player influence fields must load safely.
- Recent player action history is bounded.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Reputation labels are engineering identifiers until product copy is provided.
- Current UI does not expose player influence directly.
- Content JSON can opt into player influence conditions later without Flutter changes.
