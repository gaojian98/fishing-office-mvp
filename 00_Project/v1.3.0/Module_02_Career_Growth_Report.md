# v1.3.0 Module 02 Career Growth System Report

## Scope

Build resident career lifecycle support on top of the existing Company Organization System.

## Modified Modules

- Resident config and runtime.
- Second World Engine facade.
- Dialogue conditions.
- Story conditions.
- Dynamic Event conditions.
- Quest metrics.
- Resident Detail projection and existing Office Hub UI.
- World Simulation Context.

## New Models

- `ResidentCareerStatus`
- `ResidentCareerEvent`
- `RecruitmentNeed`
- `PromotionCandidate`

## Career Fields

- `hireDate`
- `careerLevel`
- `promotionHistory`
- `salaryLevel`
- `employmentStatus`
- `performanceScore`
- `capabilityScore`
- `careerTags`

## Runtime Impact

- `ResidentRuntimeManager` now derives a resident career status from existing resident JSON or safe defaults.
- Resident career events support Hire, Promotion, Transfer, Demotion, Resignation, and Recruitment through existing Resident Runtime and Second World Engine interfaces.
- Mutable resident career event results are stored in resident runtime overrides and saved through `residentRuntime.states[].career`.
- Departments can expose recruitment needs when department managers, team leaders, or minimum team capacity are missing.
- Promotion candidates are computed from performance, capability, and existing friendship value.
- Dialogue, Story, and Dynamic Event conditions can optionally read resident career state.
- Quest metrics can read resident career counts and recruitment/promotion summaries.
- `SecondWorldEngine` exposes resident career status, recruitment needs, promotion candidates, and hierarchy queries.
- `WorldSimulationContext` includes `residentCareerSnapshot`.

## UI Impact

- Existing Resident Detail panel now shows career information.
- No homepage UI was modified.
- No new page or homepage entry was added.

## Compatibility

- Existing resident JSON remains valid.
- Missing career fields use deterministic default values.
- Old saves without `residentRuntime.states[].career` load safely and continue to derive career state from resident config/defaults.
- Existing Dialogue, Story, Dynamic Event, and Quest content remains compatible because all career conditions are optional.
- Existing player career runtime remains separate from resident career lifecycle.

## Performance

- Resident career is derived per resident and reuses existing resident config.
- Recruitment and promotion queries iterate enabled residents and existing organization lists.
- No World Tick stage was added or reordered.
- No new top-level Manager, Engine, Repository, Runtime, Provider, or JSON type was introduced.

## Tests

- Resident career default parsing.
- Explicit career parsing.
- Recruitment need generation.
- Promotion candidate generation.
- Hire, Promotion, Transfer, Demotion, Resignation, and Recruitment career event handling.
- Resident career state save/restore through resident runtime state snapshots.
- Department manager and team leader hierarchy query.
- Career condition parsing for Dialogue, Story, and Dynamic Event.
- Resident Detail career display.

## Known Limits

- Career event results persist resident career status, but Transfer/Promotion do not automatically rewrite resident organization assignments.
- Recruitment and promotion recommendations do not automatically apply themselves.
- No new career content JSON was added.
- Resident Detail displays compact career information inside the existing Office Hub.

## Recommendation

Proceed to Module 03 after product review confirms whether career event results should also mutate organization assignment, not only resident career status.
