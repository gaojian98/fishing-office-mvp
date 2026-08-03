# office_economy

## Status

IMPLEMENTED - WAITING FOR REVIEW

## Purpose

Add company-side financial state for Fishing Office v1.3.0 without mixing company money with player wallet, fish sales, inventory, or task rewards.

## Main files

- `fishing_office_flutter/lib/models/office_economy.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/models/interactive_office.dart`
- `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart`

## Data files

- Runtime save state only.
- No new JSON type.

## Public interfaces

- `OfficeEconomyState`
- `OfficeEconomyRecord`
- `OfficeEconomySettlementResult`
- `ResidentRuntimeManager.officeEconomyState`
- `ResidentRuntimeManager.officeEconomySnapshot`
- `ResidentRuntimeManager.settleOfficeEconomy(...)`
- `SecondWorldEngine.getOfficeEconomyState()`
- `SecondWorldEngine.settleOfficeEconomy(...)`

## Direct dependencies

- Company Organization
- Resident Career
- Organization Assignment Mutation
- World Save
- World Tick shared context

## Consumers

- WorldSimulationContext economy snapshot
- Resident Detail read-only display
- future AI Decision
- future Company News / Timeline
- future Company Events

## Save fields

- `residentRuntime.officeEconomy`

## Invariants

- Company economy is separate from player wallet and backpack economy.
- Settlement IDs are stable and idempotent.
- Repeated `settlementId` does not duplicate payroll, bonus, income, cost, or history.
- Resigned residents are excluded from payroll.
- Organization mutation failure does not create economy records.
- History is bounded by `officeEconomyHistoryLimit`.
- Old saves without `residentRuntime.officeEconomy` fall back to an empty company economy with a safe default budget.
- World Tick order is unchanged.
- No new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type.

## Relevant tests

- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations

- Settlement is explicit runtime API driven; automatic daily/weekly/monthly scheduling is deferred until later modules wire company events and AI decisions.
- Department allocation uses current active resident assignments and current salary levels; no product JSON budget rules exist yet.
- Resident Detail shows a read-only economy summary only.
