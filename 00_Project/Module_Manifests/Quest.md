# Quest Module Manifest

## Purpose

Sync daily and growth task progress from world runtime events.

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

## Dependencies

- World Clock
- Daily Simulation
- Resident
- Dialogue
- Story
- Fish
- Rumor
- Festival
- Weather
- Save

## Consumers

- Task UI
- Dynamic Event
- Achievement
- Save

## Save fields

- `questRuntimeState`
- `taskRewards`

## Invariants

- Daily tasks must not refresh repeatedly on the same day.
- Rewards must not be claimable twice.
- Task UI must not calculate completion directly.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
