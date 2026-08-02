# Achievement Module Manifest

## Purpose

Unify honor, identity, collection, and task progress into runtime achievements.

## Main files

- `fishing_office_flutter/lib/core/managers/achievement_runtime_manager.dart`
- `fishing_office_flutter/lib/models/honor_config.dart`
- `fishing_office_flutter/lib/models/fish_collection_config.dart`

## Data files

- `fishing_office_flutter/assets/config/honor.json`
- `fishing_office_flutter/assets/config/identity.json`
- `fishing_office_flutter/assets/config/fish_collection.json`
- `fishing_office_flutter/assets/config/task.json`

## Public interfaces

- `getAllAchievements()`
- `getAchievementProgress(id)`
- `getUnlockedAchievements()`
- `updateAchievementProgress(event)`
- `unlockAchievement(id)`
- `equipTitle(id)`
- `getEquippedTitle()`

## Dependencies

- Quest
- Fish
- Relationship
- Story
- Rumor
- Festival
- Weather
- Resident
- World Clock
- Save

## Consumers

- Honor UI
- Profile UI
- Collection UI
- Dynamic Event
- Save

## Save fields

- `achievementRuntimeState`

## Invariants

- Achievements must not unlock twice.
- Rewards must not be paid twice.
- Pages must not compute achievement state directly.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
