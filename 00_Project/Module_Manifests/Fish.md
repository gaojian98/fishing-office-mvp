# Fish Module Manifest

## Purpose

Resolve active fish pools and fishing result selection from world context.

## Main files

- `fishing_office_flutter/lib/core/managers/fish_runtime_manager.dart`
- `fishing_office_flutter/lib/core/repository/fish_repository.dart`
- `fishing_office_flutter/lib/models/fish_catalog_config.dart`

## Data files

- `fishing_office_flutter/assets/config/fish_catalog.json`
- `fishing_office_flutter/assets/config/fish_chain.json`
- `fishing_office_flutter/assets/config/fish_collection.json`

## Public interfaces

- `getActiveFishPool()`
- `getFishPoolByLocation(locationId)`
- `getFishBiteChance(fishId, baitId)`
- `selectFishResult(context)`

## Dependencies

- World Clock
- Weather
- Festival
- Second World

## Consumers

- Fishing flow
- Dynamic Event
- Economy
- Quest
- Achievement

## Save fields

- Indirect through inventory, collection, quest, achievement, and economy state.

## Invariants

- Fish results must come from active fish pool, not all fish.
- Rarity order must remain respected.
- Bait chain must not contain cycles.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
