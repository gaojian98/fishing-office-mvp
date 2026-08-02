# achievement_runtime

## Purpose
Unify honor, identity, collection, and task achievement progress.

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

## Direct dependencies
- Quest, Fish, Relationship, Story, Rumor, Festival, Weather, Resident, Clock, Save.

## Consumers
- Honor UI, Profile UI, Collection UI, Dynamic Event, Save.

## Save fields
- `achievementRuntimeState`

## Invariants
- No duplicate unlocks.
- No duplicate rewards.
- UI must not calculate achievements.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Some achievement config is still shared with honor/identity content.
