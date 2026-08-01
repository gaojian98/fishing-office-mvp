# Runtime Integration Map

Status: Active
Scope: Pack 01-18B runtime integration
Highest Product Specification: ../SecondWorld_Product_Bible.md

## Runtime Direction

Allowed direction:

SecondWorldEngine -> WorldTickManager -> Runtime modules -> Manager state -> WorldSaveManager

Forbidden direction:

- UI directly coordinating multiple Runtime modules.
- Runtime modules forming circular update loops.
- Repository mutating Runtime state directly.
- Tick stages reading the same base world data repeatedly inside one Tick.

## Unified Tick Order

1. Clock
2. Festival
3. Weather
4. ResidentDecision
5. Resident
6. Rumor
7. Fish
8. Economy
9. Relationship
10. DynamicEvent
11. Dialogue
12. Story
13. Quest
14. Achievement
15. Save

Each Tick stage may execute once at most. If its cache key is fresh, the stage is skipped and represented in `SimulationTickResult.skippedStages`.

## Unified WorldContext

`WorldTickManager` builds one `WorldSimulationContext` per Tick after Clock advances.

Context fields:

| Field | Source | Consumer |
| --- | --- | --- |
| clock | WorldClockManager | all Runtime modules |
| festival | FestivalRuntimeManager | Resident, Dialogue, Story, Quest, Achievement, Event |
| weather | WeatherRuntimeManager | Resident, Fish, Economy, Dialogue, Story, Event |
| residentStates | ResidentRuntimeManager | Dialogue, Story, Relationship, Quest, Event |
| rumors | RumorRuntimeManager | Dialogue, Story, Quest, Event |
| fishPool | FishRuntimeManager | Fishing, Economy, Quest, Event |
| economy | EconomyRuntimeManager | Quest, Achievement, Save |
| relationships | RelationshipRuntimeManager | Dialogue, Story, Event, Achievement |
| events | DynamicEventRuntimeManager | Dialogue, Story, Quest, Achievement |
| quests | QuestRuntimeManager | Achievement, Save |
| achievements | AchievementRuntimeManager | Profile, Honor, Save |

## Unified RuntimeResult

Each Tick stage produces one `RuntimeResult`:

| Field | Meaning |
| --- | --- |
| success | Stage completed without isolated error. |
| stateChanged | Stage changed runtime state. |
| changedKeys | Runtime keys changed by the stage. |
| cacheInvalidations | Cache areas that should be invalidated. |
| saveRequired | Stage produced data that may need save. |
| errors | Isolated stage errors. |
| durationMs | Stage execution duration. |
| skipped | Stage used cache and did not run. |

## Runtime Dependency Table

| Runtime | Inputs | Outputs | Tick Stage | Cache | Save State |
| --- | --- | --- | --- | --- | --- |
| WorldClockManager | system/game clock config | world date, hour, minute, season | Clock | clock signature | worldClock, worldCalendar |
| FestivalRuntimeManager | festival config, WorldClock | active festivals, festivalTags | Festival | active festival ids, tags | activeFestivalIds snapshot |
| WeatherRuntimeManager | weather config, WorldClock | current weather, weatherTags | Weather | current weather, tags | currentWeatherId snapshot |
| ResidentDecisionManager | WorldContext, residents, weather, festival, rumor | runtime overrides | ResidentDecision | stage cache | residentRuntime through save snapshot |
| ResidentRuntimeManager | residents, schedule, activity, WorldClock | resident current state map | Resident | residentStates | residentRuntime states snapshot |
| RumorRuntimeManager | rumor config, WorldClock, festival, weather | active rumors, rumorTags | Rumor | active rumors, tags | rumorRuntime records |
| FishRuntimeManager | fish catalog, WorldClock, weather, festival | active fish pool, fish result candidates | Fish | activeFishPool | derived only, no config save |
| EconomyRuntimeManager | fish pool, weather, festival, resident demand | market multiplier, prices, demand | Economy | daily market | economyRuntimeState |
| RelationshipRuntimeManager | resident states, stories, rumors, memory | resident relationships, player relationship view | Relationship | relationship pairs | relationshipRuntimeState |
| DynamicEventRuntimeManager | events config, WorldContext | active/finished events, event effects | DynamicEvent | available/active events | dynamicEventRuntimeState |
| DialogueRuntimeManager | dialogue config, WorldContext, memory, relationship | available dialogue candidates | Dialogue | per-resident dialogue candidates | dialogueRuntimeState |
| StoryRuntimeManager | story config, WorldContext, dialogue, memory, relationship | available/finished stories | Story | per-resident story candidates | finishedStories |
| QuestRuntimeManager | task config, WorldContext, interaction history | task progress and rewards | Quest | cumulative/daily metrics | questRuntimeState, taskRewards |
| AchievementRuntimeManager | honor, identity, collection, task, WorldContext | achievement progress and equipped title | Achievement | achievement list/progress | achievementRuntimeState |
| WorldSaveManager | runtime states | persisted WorldSaveData | Save | payload signature | complete save payload |

## Cache Rules

- Cache key must include `WorldSimulationContext.signature` when a result depends on shared world state.
- Clock changes invalidate all runtime cache.
- Weather and Festival Runtime caches expose explicit `invalidateCache()`.
- No-state-change repeated Tick may skip context-dependent stages.
- Day Tick forces Save even if regular save requests were merged.

## Error Isolation

- Stage errors are recorded in `SimulationTickResult.errors`.
- Later safe stages continue running.
- Save is skipped if any prior stage failed, preventing half-complete persistence.
- `WorldSimulationContext.errors` records context collection failures.

## Performance Baseline Fields

`SimulationProfiler` records:

- tickType
- startedAt
- finishedAt
- durationMs
- executedStages
- skippedStages
- errorStages

`SimulationTickResult.cacheHitRate` derives cache effectiveness from executed/skipped stage counts.
