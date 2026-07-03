# Balance Import Guide

This project keeps the original balance workbooks intact and imports them into generic database tables.

## Workbooks

- `FishChain.xlsx`
- `EconomyBalance.xlsx`
- `Probability.xlsx`
- `TimeBalance.xlsx`
- `CompanionBalance.xlsx`
- `RewardBalance.xlsx`

## Import pattern

Each workbook becomes:

- one row in `balance_workbooks`
- one row per sheet in `balance_sheets`
- one row per workbook row in `balance_sheet_rows`

Each `balance_sheet_rows.payload` stores the row as JSON with original column names as keys.

## Why this structure

- Preserves source-of-truth Excel layout.
- Avoids premature normalization.
- Lets future APIs map fields without changing workbook shape.

## Mapping status

- Directly mappable fields are recorded in the workbook mapping report.
- Missing fields are not invented.
- Supplement fields are left for product approval.

