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
| Module 03 Organization Assignment Runtime Mutation | REVIEWED – COMMITTED | Transactional organization assignment mutation connected to career events, reporting graph, and save/restore. |
| Module 04 Office Economy | IMPLEMENTED – COMMITTED | Company-side budget, payroll, bonus, operating cost, project income, budget warning, snapshot, and bounded history. |
| Module 05 AI Decision System | IMPLEMENTED – COMMITTED | Explainable resident decisions that read organization, career, economy, relationship, personality, emotion, and memory state without directly mutating owning domains. |
| Module 06 Long-Term Memory | IMPLEMENTED – WAITING FOR REVIEW | Bounded long-term resident memory for interaction, relationship, career, organization, event, and player history. |
| Module 07 Company News & Timeline | PLANNED | Player-readable company news and structured timeline history. |
| Module 08 AI Company Events | PLANNED | Cross-runtime company events that call owning mutation/runtime interfaces. |
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

Human review for Module 06 Long-Term Memory.

Readiness: IMPLEMENTED – WAITING FOR REVIEW. Do not enter Company News & Timeline until Module 06 is reviewed and committed or explicitly accepted.

## Review And Commit Planning

- Module 01 / 02 Review Report: `00_Project/v1.3.0/MODULE_01_02_REVIEW_REPORT.md`.
- Commit Plan: `00_Project/v1.3.0/MODULE_01_02_COMMIT_PLAN.md`.
- Branch Consolidation Plan: `00_Project/v1.3.0/BRANCH_CONSOLIDATION_PLAN.md`.
