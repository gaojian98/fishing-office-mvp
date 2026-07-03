# 09_Database

PostgreSQL database base for **摸鱼 / FishingOffice**.

## Scope

This database layer is built directly from the frozen PRD, Core Engine, Economy, and Second World documents.

Included SQL files:

- `Player.sql`
- `Fish.sql`
- `FishingSession.sql`
- `Companion.sql`
- `Wallet.sql`
- `Inventory.sql`
- `Memory.sql`
- `Relationship.sql`
- `Meaning.sql`
- `Story.sql`
- `World.sql`
- `Weather.sql`
- `Today.sql`
- `Transaction.sql` (creates `wallet_transaction`)

Generated documentation:

- `ER_Diagram.mmd`
- `ER_Diagram.md`
- `ER_Diagram.png`
- `Database_Review.md`

Migration:

- `migration/001_init.sql`

## Rules

- PostgreSQL only
- UUID primary keys
- Every table has `created_at` and `updated_at`
- Foreign keys are explicit
- No new business rules added
- No balance values redesigned here

## Suggested creation order

1. `Player.sql`
2. `World.sql`
3. `Weather.sql`
4. `Today.sql`
5. `Fish.sql`
6. `FishingSession.sql`
7. `Companion.sql`
8. `Relationship.sql`
9. `Meaning.sql`
10. `Story.sql`
11. `Memory.sql`
12. `Inventory.sql`
13. `Wallet.sql`
14. `Transaction.sql`

## Notes

- `World`, `Weather`, and `Today` are separated because they belong to different Second World modules.
- `Relationship`, `Meaning`, `Story`, and `Memory` are independent tables.
- Wallet and transaction data are separated so future API layers can write ledger logic cleanly.
- `Transaction.sql` uses the table name `wallet_transaction` to avoid PostgreSQL reserved-word conflicts.
- `migration/001_init.sql` executes the full DDL in creation order.
- `Database_Review.md` records the sprint-level delivery check.
