# economy_runtime

## Purpose
Calculate fish prices, market multiplier, resident demand, and reward multiplier.

## Main files
- `fishing_office_flutter/lib/core/managers/economy_runtime_manager.dart`

## Data files
- Existing fish, store, and task configs.

## Public interfaces
- `getFishSellPrice(fishId)`
- `getFishBuyPrice(fishId)`
- `getMarketMultiplier()`
- `getResidentDemand(residentId)`
- `calculateReward(taskId)`
- `updateMarket()`

## Direct dependencies
- Fish, Quest, Resident, Festival, Weather, World Clock, Save.

## Consumers
- Store, Fishing result, Quest, Achievement, Save.

## Save fields
- `economyRuntimeState`

## Invariants
- No recharge, VIP, withdrawal, or ad pressure.
- No negative assets.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Balancing changes require targeted balance validation.
