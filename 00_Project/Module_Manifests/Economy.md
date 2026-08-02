# Economy Module Manifest

## Purpose

Calculate market multipliers, fish prices, resident demand, and task reward multipliers.

## Main files

- `fishing_office_flutter/lib/core/managers/economy_runtime_manager.dart`

## Data files

- Existing fish, store, and task config files.

## Public interfaces

- `getFishSellPrice(fishId)`
- `getFishBuyPrice(fishId)`
- `getMarketMultiplier()`
- `getResidentDemand(residentId)`
- `calculateReward(taskId)`
- `updateMarket()`

## Dependencies

- Fish
- Quest
- Resident
- Festival
- Weather
- World Clock
- Save

## Consumers

- Store
- Fishing result
- Quest
- Achievement
- Save

## Save fields

- `economyRuntimeState`

## Invariants

- Economy must not add recharge, VIP, withdrawal, or ad pressure.
- Prices must not create negative assets.
- Daily refresh should be deterministic for the same world state.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
