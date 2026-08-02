# resident_personality

## Purpose
Map existing resident personality strings into runtime traits.

## Main files
- `fishing_office_flutter/lib/models/resident_personality_context.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`

## Data files
- Existing `personality` fields in resident config.

## Public interfaces
- `getResidentPersonalityContext(id)`
- `getAllResidentPersonalityContexts()`
- `ResidentPersonalityContext.normalizeTrait(raw)`

## Direct dependencies
- Resident config, Location.

## Consumers
- Resident Decision, Dialogue, Story, Rumor, Relationship, Dynamic Event, Second World, Save.

## Save fields
- `recentPersonalityInfluences`
- `lastPersonalityDecisionReason`
- `interactionPreferenceOverride`

## Invariants
- Unknown traits fall back to `calm`.
- Do not save full personality config.
- Personality affects weights only, not absolute outcomes.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Content JSON has limited personality-specific entries so far.
