# v1.3.0 Branch Consolidation Plan

## Decision

The current review branch remains:

- `codex/v1.3-company-organization`

The long-term development branch remains:

- `feature/v1.3.0-office-ai`

No branch was deleted, renamed, switched, merged, rebased, stashed, reset, cleaned, committed, or pushed in this task.

## Current Branch Facts

- `codex/v1.3-company-organization` points to `dfc701b0cec8ed0bf06494dd47b1e25d673a5590`.
- Local `feature/v1.3.0-office-ai` points to the same commit.
- Current working tree contains uncommitted Module 01 / Module 02 / Module 03 preparation / documentation changes.
- Remote `feature/v1.3.0-office-ai` was not present in the local remote refs at the time of the previous branch check.

## Safe Consolidation Flow

1. Continue review on `codex/v1.3-company-organization`.
2. Do not move uncommitted code between branches.
3. Finish human Review for Module 01 and Module 02.
4. Approve the atomic commit plan.
5. Create commits on `codex/v1.3-company-organization` using explicit file lists and `git add -p` where required.
6. Run full validation after each code commit group:
   - `dart format --set-exit-if-changed lib test`
   - `flutter analyze`
   - `flutter test`
   - `flutter build web --release`
   - `git diff --check`
7. Confirm working tree is clean.
8. Switch to `feature/v1.3.0-office-ai` only after the worktree is clean.
9. Bring reviewed commits into `feature/v1.3.0-office-ai` with ordinary merge or cherry-pick.
10. Do not use force push.
11. Do not use `reset --hard`.
12. Do not delete `codex/v1.3-company-organization` until the long-term branch validates.

## Branch Consolidation Risks

- Current source/test changes are mixed; committing whole files mechanically would combine Module 01, Module 02, and Module 03 work.
- The safest path is reviewed atomic commits first, branch consolidation second.
- Module 03 should not be treated as fully reviewed until the Module 01 / 02 commit split and Review debt are accepted.

## Module 03 Readiness

Current readiness:

`GO - REQUIRED DEBT RESOLUTION`

Conditions:

- Module 01 and Module 02 are reviewed as PASS WITH DEBT.
- Module 03 is required before Office Economy.
- Module 03 completion must explicitly resolve career / organization idempotency debt.
- Module 03 must not be committed until the current mixed worktree is reviewed and staged atomically.
