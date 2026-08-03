# Module 05 AI Decision System Report

## Status

IMPLEMENTED - WAITING FOR REVIEW

## Scope

Module 05 extends the existing `ResidentDecisionManager` into an explainable resident decision recommendation layer.

It reads existing runtime state:

- resident current state
- organization assignment
- resident career status
- office economy state
- relationship level
- personality context
- mood
- memory tags
- dialogue candidates
- story candidates
- weather
- festival
- rumors

It does not create a new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type.

## Implemented Model Changes

`ResidentDecision` now includes:

- `decisionId`
- `type`
- `score`
- `confidence`
- `target`
- `consequence`
- `cooldown`

Supported decision types currently include:

- `promotion_request`
- `transfer_choice`
- `resignation_risk`
- `training`
- `help_colleague`
- `refuse_interaction`
- `daily_route`

## Runtime Behavior

`ResidentDecisionManager` now:

- generates stable decision IDs by resident, day, and decision type
- evaluates career and organization context without mutating them
- reads office economy warnings and budget pressure
- records processed decision IDs idempotently
- stores decision cooldowns
- caps decision history at 80 entries
- supports save/load of decision runtime state

## Domain Ownership

AI Decision does not directly execute:

- promotion
- transfer
- demotion
- resignation
- organization assignment
- office economy settlement
- player reward mutation

Future modules must route those changes through the owning runtime interfaces.

## Compatibility

- Existing `decideNextActivity`, `decideNextLocation`, `decideNextDialogueTarget`, and `decideNextStoryTarget` remain available.
- Old decision state without the new fields falls back to safe defaults through `ResidentDecision.fromJson`.
- No existing JSON schema is changed.
- World Tick order is unchanged.

## Tests

Added coverage in `framework_smoke_test.dart` for:

- career state producing a `promotion_request`
- AI recommendation not directly changing organization assignment
- idempotent decision execution
- bounded processed decision tracking
- cooldown recording
- office economy budget pressure producing `resignation_risk`
- AI recommendation not directly resigning a resident
- save/load of decision state

## Performance

The module reuses existing runtime contexts and does not introduce all-resident pairwise scanning.

## Known Limits

- Scoring is deterministic and rule-based.
- Decision execution records processing only; follow-up modules may translate approved decisions into domain-specific runtime calls.
- Tests remain in `framework_smoke_test.dart`; a future cleanup can split them into dedicated module tests.

## Validation

Latest targeted validation:

- `dart format lib test` PASS
- `flutter test test/framework_smoke_test.dart --plain-name "resident decision manager adapts activity from world context"` PASS

Full validation should be recorded after final module verification.
