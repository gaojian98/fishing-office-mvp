# quest_runtime

## Purpose
Track daily and growth task progress from world events.

## Main files
- `fishing_office_flutter/lib/core/managers/quest_runtime_manager.dart`
- `fishing_office_flutter/lib/models/task_config.dart`

## Data files
- `fishing_office_flutter/assets/config/task.json`

## Public interfaces
- `recordWorldEvent(type, id, amount)`
- `recordLocationEvent(type, locationId)`
- `syncFromRuntime()`
- `refreshDailyTasks()`
- `claimReward(taskId)`

## Direct dependencies
- Clock, Daily Simulation, Resident, Dialogue, Story, Fish, Rumor, Festival, Weather, Save.

## Consumers
- Task UI, Dynamic Event, Achievement, Save.

## Save fields
- `questRuntimeState`
- `taskRewards`

## Invariants
- Rewards cannot be claimed twice.
- Same-day daily tasks must not refresh repeatedly.
- UI must not calculate task completion.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Dedicated task test folder is still a future cleanup.
