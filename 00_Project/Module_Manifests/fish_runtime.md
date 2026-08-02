# fish_runtime

## Purpose
Resolve active fish pools and fishing result selection.

## Main files
- `fishing_office_flutter/lib/core/managers/fish_runtime_manager.dart`
- `fishing_office_flutter/lib/models/fish_catalog_config.dart`
- `fishing_office_flutter/lib/core/repository/fish_repository.dart`

## Data files
- `fishing_office_flutter/assets/config/fish_catalog.json`
- `fishing_office_flutter/assets/config/fish_chain.json`
- `fishing_office_flutter/assets/config/fish_collection.json`

## Public interfaces
- `getActiveFishPool()`
- `getFishPoolByLocation(locationId)`
- `getFishBiteChance(fishId, baitId)`
- `selectFishResult(context)`

## Direct dependencies
- World Clock, Weather, Festival, Second World.

## Consumers
- Fishing flow, Dynamic Event, Economy, Quest, Achievement.

## Save fields
- Indirect through inventory, collection, task, achievement, economy.

## Invariants
- Results come from active pool.
- Rarity hierarchy should remain intact.
- Bait chain must not cycle.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Fish content updates should be JSON-only.
