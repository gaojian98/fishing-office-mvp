# Module 04 Office Economy Report

## Status

IMPLEMENTED - WAITING FOR REVIEW

## Scope

- Company financial state
- Department budget tracking
- Payroll
- Bonus
- Operating cost
- Project income
- Budget warning
- Economy snapshot
- Bounded economy history
- Save / Restore fallback
- Resident Detail read-only display

## Modified Modules

- Resident Runtime owns company-side office economy state.
- SecondWorldEngine exposes read-only state and settlement facade.
- WorldSave stores `residentRuntime.officeEconomy`.
- WorldTick includes `officeEconomy` under the shared economy snapshot.
- Office Hub Resident Detail displays a read-only company economy summary.

## Runtime Behavior

- `settleOfficeEconomy(...)` creates one `OfficeEconomyRecord` for a stable settlement id.
- Repeating the same settlement id returns idempotent success.
- Active residents are selected from current organization and career state.
- Resigned residents are excluded from payroll.
- Department filtering uses current organization assignment after mutation.
- Payroll uses current resident salary level and career level.
- Bonus, operating cost, and project income are recorded separately.
- History is capped by `officeEconomyHistoryLimit`.

## Compatibility

- No raw resident JSON is rewritten.
- No new JSON config type is added.
- Old saves without `residentRuntime.officeEconomy` restore to a safe empty state.
- Company economy remains separate from player wallet, inventory, task rewards, and fish market economy.

## Validation

- Targeted smoke test: PASS.
- Full validation pending final module check.

## Known Limits

- Automatic daily / weekly / monthly settlement scheduling is not yet wired.
- No company news or timeline is generated in this module.
- No AI decision behavior is implemented in this module.

## Next Step

Human review, then local commit with:

`feat(economy): add office economy and payroll runtime`
