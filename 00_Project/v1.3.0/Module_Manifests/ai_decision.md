# ai_decision

## Purpose
Provide explainable resident decision recommendations from existing world, resident, organization, career, economy, relationship, personality, emotion, memory, dialogue, and story state.

## Main files
- `fishing_office_flutter/lib/core/managers/resident_decision_manager.dart`

## Data files
- Runtime state only.
- No new JSON type.

## Public interfaces
- `ResidentDecision`
- `ResidentDecision.fromJson(...)`
- `ResidentDecision.toJson()`
- `ResidentDecisionManager.decisions`
- `ResidentDecisionManager.decisionHistory`
- `ResidentDecisionManager.processedDecisionIds`
- `ResidentDecisionManager.decisionCooldowns`
- `ResidentDecisionManager.decisionFor(residentId)`
- `ResidentDecisionManager.runResidentDecision()`
- `ResidentDecisionManager.executeDecision(decisionId)`
- `ResidentDecisionManager.toDecisionStateJson()`
- `ResidentDecisionManager.loadDecisionState(...)`

## Direct dependencies
- Resident Runtime
- Dialogue Runtime
- Story Runtime
- Weather Runtime
- Festival Runtime
- Rumor Runtime
- Resident Memory
- Relationship
- Organization Context
- Resident Career
- Office Economy
- World Clock
- Second World Engine

## Consumers
- World Tick
- Second World Engine
- Future Company News
- Future AI Company Events

## Save fields
- `decisions`
- `processedDecisionIds`
- `decisionCooldowns`
- `decisionHistory`

## Invariants
- Decisions are recommendations and do not directly mutate organization, career, economy, player wallet, inventory, quest rewards, or achievement state.
- `decisionId` is stable per resident, day, and decision type.
- Repeated `executeDecision(decisionId)` is idempotent.
- Decision history is bounded to 80 records.
- Cooldowns are stored per resident.
- Career or organization consequences must be executed by owning runtime interfaces in future modules.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Current decision scoring is deterministic and rule-based, not a network AI model.
- Decision execution records recommendation processing only; it intentionally does not perform promotion, transfer, resignation, or economy mutation.
- Dedicated AI decision test files are not split out yet.
