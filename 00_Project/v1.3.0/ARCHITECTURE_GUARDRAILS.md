# v1.3.0 Architecture Guardrails

## Purpose

This file defines the architecture rules that must stay stable while Fishing Office v1.3.0 moves toward long-term world evolution.

## Guardrails

1. Do not add a top-level Manager, Engine, Repository, Runtime, Provider, or page by default.
2. UI must not directly modify core business state.
3. Career changes must use the unified Organization Mutation path.
4. Organization, Career, and Economy state must remain mutually consistent.
5. Do not modify the existing World Tick order without an ADR.
6. High-frequency Tick paths must not use O(n²) resident comparisons.
7. The 100-resident scale must remain stable.
8. Every new save field must have old-save defaults and fallback behavior.
9. Every transaction-like state write must be idempotent.
10. Every long-term history list must define a capacity, expiry, compression, or summary strategy.
11. Do not reimplement an existing Runtime rule in another module.
12. Analytics is read-only aggregation and must not modify business state.
13. Pages consume Snapshot, Context, RuntimeResult, Provider state, or facade methods; pages do not own rules.
14. Do not modify v1.2.0 Tag, Release records, Railway Production, or production deployment configuration.
15. One task should complete one module unless the user explicitly requests grouped release or documentation work.
16. Do not enter the next module before human review when a task says to wait.
17. Planned content must not be documented as implemented.
18. Multiple modules must not directly modify the same field without a unified owning interface.

## Organization And Career Ownership

- Resident Runtime owns resident organization and resident career runtime state.
- SecondWorldEngine exposes facade access for upper layers.
- Career events that change organization assignment must not separately patch organization fields.
- Organization Mutation must validate before writing and must fail without partial state changes.

## Save Boundary

- Runtime state goes to Save / Runtime State, not static JSON.
- Static JSON remains initial content and configuration.
- Missing v1.3 fields in old saves must safely restore from existing resident defaults.

## Review Boundary

- Unreviewed code can exist in the working tree, but documentation must label it as unreviewed or waiting for review.
- GO requires branch state, module state, and review state to be explicit.
