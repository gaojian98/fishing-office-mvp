# v1.3.0 Design Decisions

## DD-001 Company Organization Lives Inside Existing Resident Runtime

Status: Accepted

Decision: Company, department, team, position, career status, and organization assignment mutation stay inside existing resident runtime ownership.

Reason: Product describes organization capability, not a new system boundary. Adding another top-level manager would duplicate resident ownership and increase runtime coupling.

Impact: Resident Runtime remains the single write owner for resident organization and career state. SecondWorldEngine exposes facade methods for upper layers.

## DD-002 Runtime Mutation Does Not Rewrite Resident JSON

Status: Accepted

Decision: Organization mutation writes runtime override state and save data only. Resident config remains the fallback source.

Reason: Existing content stays compatible and v1.2.0 saves can load without migration pressure.

Impact: Save/restore must include organization overrides, mutation history, and processed mutation source ids. Missing fields fall back safely.

## DD-003 sourceId Is The Organization Mutation Idempotency Key

Status: Accepted

Decision: Repeated organization mutation with the same sourceId returns an idempotent success and does not add duplicate history.

Reason: Career events, dynamic events, and future quest/story outcomes may retry after save/load or duplicate dispatch.

Impact: Any caller that needs exactly-once semantics must pass a stable sourceId.

## DD-004 Capacity Rules Use Existing Position Hierarchy

Status: Accepted

Decision: Department manager and director positions are capacity-limited by department/company, team leader is capacity-limited by team, and staff/specialist positions are multi-occupant.

Reason: No dedicated position capacity JSON exists yet, and this keeps Module 03 within existing organization metadata.

Impact: Future product-provided capacity fields can replace the current inferred capacity without changing UI.

## DD-005 Organization Mutation Is The Only Assignment Write Path

Status: Accepted

Decision: Hire, promotion, transfer, demotion, resignation, release position, and assignment changes use the Resident Runtime organization mutation path.

Reason: Career and organization state must stay transactionally consistent, idempotent, and save-compatible.

Impact: Career events request organization changes through mutation APIs. UI, Dialogue, Story, Quest, and Dynamic Event read the unified current organization state and must not patch assignment fields directly.


## DD-006 Reporting Graph Is Part Of Current Organization Assignment

Status: Accepted

Decision: `OrganizationAssignment` persists `reportsToResidentId` as current runtime state, separate from mutation history.

Reason: Dialogue, Story, Quest, Dynamic Event, Economy, and future AI Decision modules need the current reporting graph without reconstructing it from history.

Impact: Save/restore must include `reportsToResidentId` through the existing organization assignment state. Missing values from old saves fall back to an empty reporting relation.

## ADR-011 Career Changes Must Use Unified Organization Mutation

Status: Accepted

Context: Resident career events can change position, team, department, reporting relation, and employment status. Updating these fields independently creates inconsistent world state.

Decision: Career changes that affect organization assignment must go through the unified organization Mutation interface owned by Resident Runtime.

Rationale: One mutation path gives validation, transaction behavior, idempotency, history, and save/restore consistency.

Consequences: Dialogue, Story, Quest, Dynamic Event, and UI consumers read one current organization state. Callers cannot separately edit career and organization.

Alternatives: Let each feature directly update resident fields. Rejected because it duplicates validation and allows partial writes.

Follow-up: Future AI Decision and Company Event modules must call the same mutation path.

## ADR-012 Current Organization State And Organization History Are Separate

Status: Accepted

Context: Runtime consumers need fast access to current organization state, while timeline, news, memory, and audit flows need historical records.

Decision: Store current assignment separately from mutation history.

Rationale: Current state must be queryable without scanning all history. History must survive role changes and resignations.

Consequences: Save data must include both current runtime assignment and bounded mutation history.

Alternatives: Reconstruct current assignment from history on every query. Rejected for performance and fallback complexity.

Follow-up: Define history retention and compression when timeline modules are implemented.

## ADR-013 Company News And Company Timeline Are Separate

Status: Accepted

Context: Future company events need both player-readable summaries and structured state history.

Decision: Company News is presentation-oriented; Company Timeline is structured history with stable event IDs.

Rationale: News can be summarized, localized, and merged. Timeline must remain stable for save/restore, analytics, and story conditions.

Consequences: UI must not treat news text as the source of truth.

Alternatives: Use one news list for all history. Rejected because readable text is not a reliable data model.

Follow-up: Define timeline schema before Company News implementation.

## ADR-014 Player Influences World But Does Not Directly Control All State

Status: Accepted

Context: The product goal is a living office world, not an admin simulator.

Decision: Player actions influence weights, relationships, reputation, events, and indirect outcomes, but cannot bypass runtime validation or force arbitrary state.

Rationale: World autonomy preserves surprise, continuity, and believable resident behavior.

Consequences: UI actions must call runtime interfaces and accept blocked or delayed outcomes.

Alternatives: Give player direct write access to resident, organization, career, and economy state. Rejected because it breaks world autonomy and consistency.

Follow-up: Future player influence features must define clear boundaries and cooldowns.

## ADR-015 Economy Career And Organization Changes Require Idempotency And Transaction Consistency

Status: Accepted

Context: Economy, career, and organization events may be retried by save/load, dynamic events, quests, or future AI decisions.

Decision: State-changing events in these domains must have stable sourceId or mutationId and must commit all-or-nothing.

Rationale: Prevent duplicate salary, repeated promotion, double rewards, and partial organization assignment.

Consequences: Runtime interfaces must reject or idempotently ignore duplicate source IDs.

Alternatives: Depend on caller discipline. Rejected because cross-module retries are expected.

Follow-up: Apply the same pattern to future Company Economy settlement keys.

## ADR-016 Long-Term History Must Have Capacity And Summary Strategy

Status: Accepted

Context: A persistent world can generate unbounded interaction, career, memory, news, and timeline records.

Decision: Every long-term history list must define retention, capacity, expiry, compression, or summary behavior.

Rationale: Save files, runtime memory, and UI queries must remain bounded.

Consequences: Modules cannot add infinite append-only history without a limit.

Alternatives: Keep all records forever. Rejected for performance and save growth risk.

Follow-up: Define concrete capacities per timeline, news, memory, and economy module.

## ADR-017 World Tick Separates Lightweight And Heavy Tasks

Status: Accepted

Context: The world must support frequent updates without making 100 resident simulation expensive.

Decision: High-frequency Tick executes lightweight tasks; heavy aggregation runs on day, week, month, or explicit events.

Rationale: This preserves responsiveness and prevents repeated full-world recomputation.

Consequences: UI opening a page must not trigger full Tick or heavy calculations.

Alternatives: Run all systems every Tick. Rejected due to O(n²) and repeated work risk.

Follow-up: Future modules should state their Tick frequency and skip conditions.

## ADR-018 Office Analytics Is Read-Only Aggregation

Status: Accepted

Context: Future analytics may summarize residents, departments, economy, relationships, and events.

Decision: Office Analytics can aggregate and expose snapshots, but cannot directly mutate business state.

Rationale: Analytics should be observable evidence, not a hidden decision writer.

Consequences: Any action suggested by analytics must go through the owning runtime interface.

Alternatives: Let analytics auto-correct or mutate runtime state. Rejected because it hides side effects and breaks module ownership.

Follow-up: Define analytics snapshot contracts after Company Timeline exists.

## ADR-019 Position Release And Target Occupancy Are One Transaction

Status: Accepted

Context: Promotion, transfer, demotion, hire, and resignation can change both the old organization assignment and the target assignment.

Decision: Releasing the old position and occupying the target position must be validated and committed as one transaction.

Rationale: A half-written assignment can leave residents without a valid role, overfill a position, or create contradictory organization state.

Consequences: Mutation code must validate every target before writing. Failure must leave current organization, career, and history unchanged.

Alternatives: Release first, then attempt target assignment. Rejected because target failure would corrupt current assignment.

Follow-up: Future Economy and AI Decision modules must use the same transaction boundary.

## ADR-020 Repeated mutationId Must Not Duplicate State Or History

Status: Accepted

Context: Runtime events can be retried after save/restore, repeated UI submissions, dynamic event retries, or future AI decision retries.

Decision: The same sourceId or mutationId must be idempotent.

Rationale: Organization and career mutations must never duplicate promotion history, release the same role twice, or write duplicate timeline records.

Consequences: Mutation history and processed mutation IDs must be saved and restored.

Alternatives: Depend on each caller to avoid duplicates. Rejected because retry behavior is cross-module.

Follow-up: Company News, Timeline, and Economy settlement keys must follow the same pattern.

## ADR-021 Career Runtime Must Not Directly Patch Organization Fields

Status: Accepted

Context: Career lifecycle events can require organization changes, but directly writing organization fields from Career logic would bypass organization validation.

Decision: Career Runtime may request organization changes only through the unified Organization Mutation interface.

Rationale: Organization consistency requires one owner for validation, capacity, reporting, transaction, idempotency, and history.

Consequences: Any direct career-to-organization field write is architecture debt and must be routed through Organization Mutation before review approval.

Alternatives: Let Career Runtime patch assignment fields internally. Rejected because it duplicates and fragments organization rules.

Follow-up: Audit future Career, AI Decision, Economy, and Dynamic Event work for direct organization writes.

## ADR-022 Organization Mutation Must Persist And Validate Reporting Graph

Status: Accepted

Context: Organization Mutation can change a resident's reporting target. Storing only mutation history makes current reporting relationships expensive and ambiguous for runtime consumers.

Decision: Current organization assignment stores `reportsToResidentId`, and Organization Mutation validates the full reporting chain before committing.

Rationale: Persisting the current reporting edge makes Save/Restore, Dialogue, Story, Quest, Dynamic Event, Economy, and future AI Decision consumers read one consistent organization state. Multi-level cycle detection prevents invalid management graphs.

Consequences: Old saves without `reportsToResidentId` remain compatible through empty fallback. Future modules must use Organization Mutation for reporting changes and must not infer current reporting from history.

Alternatives: Store reporting only in mutation history. Rejected because consumers would need to rebuild current graph and could miss invalid cycles.

Follow-up: Future Company Timeline may summarize reporting changes, but it must not replace current assignment as the source of truth.
