# v1.3.0 Roadmap

## Version Goal

Build the company organization foundation used by resident career growth, office decisions, dialogue, story, quest, dynamic event, and future economy modules.

Primary long-term design reference:

- `00_Project/v1.3.0/LONG_TERM_WORLD_EVOLUTION_DESIGN.md`

## Modules

| Module | Status | Scope |
|---|---|---|
| Module 01 Company Organization System | REVIEWED – PASS WITH DEBT | Company, Department, Team, Position, resident organization context. Debt: inferred capacity/reporting graph and mixed commit split. |
| Module 02 Career Growth System | REVIEWED – PASS WITH DEBT | Resident career status, career events, recruitment needs, promotion candidates, Resident Detail career projection. Debt: supplemental career event idempotency must be resolved by Module 03. |
| Module 03 Organization Assignment Runtime Mutation | GO – REQUIRED DEBT RESOLUTION | Transactional organization assignment mutation connected to career events and save/restore. Required before Office Economy. |
| Long-Term World Evolution Design Documentation | DOCUMENTED – WAITING FOR REVIEW | Design guardrails for v1.3.0 and future v1.4.0 / v1.5.0 / v2.0.0 evolution. |

## Active Constraints

- Do not add a top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type for v1.3.0 organization work unless explicitly approved.
- Do not modify the World Tick order.
- Do not modify v1.2.0 tags, release files, Railway production, or homepage UI.
- Organization and career runtime changes must preserve old save fallback.
- Planned content must not be documented as implemented.
- Core rule changes require a new or updated ADR.

## Long-Term Evolution Direction

| Version | Direction | Status |
|---|---|---|
| v1.3.0 | Living AI Company foundation | In progress |
| v1.4.0 | Autonomous Resident Decisions | Planned |
| v1.5.0 | Advanced Company Economy & Social Evolution | Planned |
| v2.0.0 | Persistent AI Office World | Planned |

## Next Candidate Module

Module 03 Organization Assignment Runtime Mutation.

Readiness: GO – REQUIRED DEBT RESOLUTION. Module 03 may continue after the Module 01 / 02 review debt and atomic commit plan are accepted.

## Review And Commit Planning

- Module 01 / 02 Review Report: `00_Project/v1.3.0/MODULE_01_02_REVIEW_REPORT.md`.
- Commit Plan: `00_Project/v1.3.0/MODULE_01_02_COMMIT_PLAN.md`.
- Branch Consolidation Plan: `00_Project/v1.3.0/BRANCH_CONSOLIDATION_PLAN.md`.
