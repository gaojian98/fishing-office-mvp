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

## DD-007 Office Economy Is Company-Side Runtime State

Status: Accepted

Decision: Company budget, department budgets, payroll, bonuses, operating costs, project income, warnings, and office economy history live as runtime state owned through Resident Runtime and saved under `residentRuntime.officeEconomy`.

Reason: Office Economy depends on current organization assignment and resident career state. It must remain separate from player wallet, backpack, fish sales, and task rewards.

Impact: UI can read office economy snapshots, but cannot directly modify company finance. Future AI Decision, News, Timeline, and Company Event modules must use stable settlement IDs and owning runtime APIs.

## DD-008 Office Economy Settlement IDs Are Idempotency Keys

Status: Accepted

Decision: `settlementId` is the idempotency key for payroll, bonus, operating cost, project income, budget allocation, and economy history records.

Reason: Daily, weekly, and monthly settlement may retry after save/load or event replay. Duplicate settlement must not pay salary twice or duplicate financial history.

Impact: Repeated settlement IDs return idempotent success and preserve existing state. Future scheduled settlement must generate stable period-based settlement IDs.

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

## ADR-023 Company Economy Must Stay Separate From Player Economy

Status: Accepted

Context: v1.3.0 introduces office payroll, department budgets, operating cost, and project income while the game already has player-facing fish coins, inventory, task rewards, and market pricing.

Decision: Office Economy records company-side finance only. It does not write player wallet, inventory, task reward, or fish market state.

Rationale: Company simulation should influence the office world without becoming a second player reward loop or corrupting player assets.

Consequences: Office Economy can be shown read-only in Office Hub / Resident Detail and can feed future AI Decision, News, Timeline, and Company Events. Player rewards must continue using their existing managers.

Alternatives: Reuse player economy balances for company finance. Rejected because it mixes simulation state with player assets and creates reward duplication risk.

Follow-up: Future company events may derive consequences from office economy, but must call owning runtime interfaces.

## ADR-024 Office Economy Settlements Must Be Bounded And Idempotent

Status: Accepted

Context: Payroll, bonuses, costs, and income can run daily, weekly, monthly, or from future company events. Save/load retries can re-dispatch the same settlement.

Decision: Every office economy settlement uses a stable `settlementId`, and office economy history is capped.

Rationale: This prevents duplicate salary, repeated budget changes, and unbounded save growth.

Consequences: Old saves without office economy state fall back safely. Repeated settlement IDs return idempotent success. Future automatic settlement must reuse the same key strategy.

Alternatives: Append every settlement attempt. Rejected because it creates duplicated finance and unbounded history.

Follow-up: Company News and Timeline should summarize economy records without becoming the source of truth.

## ADR-025 AI Decision Is A Read-Only Recommendation Layer

Status: Accepted

Context: Resident decisions can consider organization, career, office economy, relationship, personality, emotion, memory, dialogue, story, weather, festival, and rumor state.

Decision: AI Decision may score, explain, persist, and mark decisions as processed, but it must not directly mutate organization assignment, career state, office economy, player assets, quest rewards, or achievement state.

Rationale: Domain ownership remains with the existing mutation/runtime interfaces, which already enforce validation, idempotency, transaction consistency, and save compatibility.

Consequences: Future modules that execute AI recommendations must call the owning runtime interface, such as Organization Mutation for promotions or transfers and Office Economy for settlements.

Alternatives: Let AI Decision directly perform promotions, resignations, or economy changes. Rejected because it would bypass Module 03 transaction rules and make side effects harder to audit.

Follow-up: Company Events can translate approved AI recommendations into domain calls, but must preserve the same idempotency keys.

## ADR-026 AI Decision History And Execution Must Be Bounded And Idempotent

Status: Accepted

Context: Resident decisions may run repeatedly during Tick, save/load, daily simulation, and future event processing.

Decision: Decision IDs must be stable, executed decisions must be idempotent, cooldowns must be stored by resident, and decision history must be bounded.

Rationale: Repeated evaluation should not duplicate history, spam decisions, or grow save data forever.

Consequences: `executeDecision(decisionId)` records processing only once, and decision history is capped.

Alternatives: Append every evaluation and execution attempt. Rejected because it creates noisy history and unbounded persistence.

Follow-up: Long-Term Memory and Company Timeline should summarize AI decisions rather than copying every repeated evaluation.

## ADR-027 Long-Term Resident Memory Must Be Bounded And Source-Id Idempotent

Status: Accepted

Context: Resident memory can now include interaction, relationship, career, organization, event, and player history across a long-running world.

Decision: Long-term memories are stored under the existing resident memory owner, require stable `sourceId`, and are capped per resident.

Rationale: Memory should influence future decisions and stories without becoming an unbounded event log or duplicating retried events.

Consequences: Repeated `sourceId` returns the existing memory. Each resident keeps at most 60 long-term memories, with important memories retained ahead of low-importance memories.

Alternatives: Create a separate top-level memory runtime. Rejected because `ResidentMemoryEngine` already owns resident memory and save compatibility.

Follow-up: Company Timeline may summarize important long-term memories, but must not become the source of truth for resident memory.

## ADR-028 Memory Consumers Must Read Summary Or Tags

Status: Accepted

Context: AI Decision, Dialogue, Story, Dynamic Event, and future News need memory context.

Decision: Consumers should read resident memory summary or memory tags exposed by the memory owner. They must not scan and reinterpret full long-term histories in their own modules.

Rationale: One memory owner preserves expiry, decay, importance, deduplication, and capacity behavior.

Consequences: AI Decision reads `ResidentMemorySummary` when available. Dialogue and Story continue using memory tags and existing memory context.

Alternatives: Let each consumer implement custom memory filtering. Rejected because it duplicates memory rules and increases performance risk.

Follow-up: If richer memory retrieval is needed, extend `ResidentMemoryEngine` with query helpers instead of duplicating logic in consumers.
