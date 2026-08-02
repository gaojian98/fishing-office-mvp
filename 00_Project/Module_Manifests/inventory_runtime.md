# inventory_runtime

## Purpose
Expose inventory items, fish storage, quantities, and item actions.

## Main files
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/models/inventory_config.dart`
- `fishing_office_flutter/lib/pages/inventory/inventory_dialog_page.dart`

## Data files
- `fishing_office_flutter/assets/config/inventory.json`

## Public interfaces
- Inventory manager view APIs in `app_managers.dart`
- sell/release/keep fish operations through existing managers

## Direct dependencies
- Fish, Wallet/Asset state, Transaction state.

## Consumers
- Inventory UI, Fishing result, Store, Profile.

## Save fields
- Current scope uses provider/manager state and mock data; verify before adding persistence.

## Invariants
- UI must not directly mutate wallet or transaction records.
- Inventory actions should flow through existing manager APIs.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Inventory runtime is currently manager-view based, not a separate runtime manager.
