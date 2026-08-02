# Feature 03 Resident Personality Integration Report

## Personality Tag System

Supported normalized traits:

- `outgoing`
- `introverted`
- `hardworking`
- `lazy`
- `gossipy`
- `serious`
- `optimistic`
- `pessimistic`
- `curious`
- `cautious`
- `kind`
- `competitive`
- `playful`
- `calm`
- `sensitive`

Residents may have more than one trait. Unknown or empty traits fall back to `calm`.

## Compatibility Mapping

Existing `personality` values remain unchanged in JSON. `ResidentPersonalityContext` maps current English and Chinese aliases into normalized traits.

Examples:

- `talkative`, `informed`, `witty`, `八卦` -> `gossipy`
- `quiet`, `solitary`, `awkward`, `内向` -> `introverted`
- `practical`, `reliable`, `organized`, `勤奋` -> `hardworking`
- `careful`, `watchful`, `谨慎` -> `cautious`
- `gentle`, `nurturing`, `tender`, `善良` -> `kind`
- `funny`, `dreamy`, `幽默` -> `playful`
- unknown values -> `calm`

## Personality And Location Rules

Personality now affects location weight only. It does not replace base schedule, weather, festival, capacity, story, or temporary override rules.

Rules:

- `outgoing`: prefers `pantry`, `reception`, `coffee_shop`, `meeting_room`.
- `introverted`: prefers `workstation`, `balcony`, `home`, `printing_area`.
- `hardworking`: prefers `workstation`, `meeting_room`, `manager_room`.
- `lazy`: prefers `pantry`, `balcony`, `coffee_shop`, `home`.
- `gossipy`: prefers `pantry`, `reception`, `coffee_shop`.
- `serious`: prefers `workstation`, `meeting_room`, `manager_room`.
- `curious`: prefers `printing_area`, `reception`, `dock`, `seaside`.
- `calm`: prefers `balcony`, `park`, `home`, `seaside`.

All location choices still pass through `LocationContext.isReasonableForPhase()`.

## Personality And Schedule Rules

`ResidentDecisionManager` now uses personality as a small deviation layer:

- `hardworking`, `serious`, and `competitive` residents are more likely to remain in work locations and overtime.
- `lazy` residents are less likely to overtime and may stretch break activities.
- `gossipy` residents prefer discussion locations when rumors are active.
- `curious` residents drift toward discovery-friendly locations when stories or rumors exist.
- `cautious` residents prefer safer indoor behavior during storm-like weather.
- `introverted` residents prefer quieter friend interactions.

Decision reasons include explainable tags such as:

- `personality_hardworking`
- `personality_introverted_relationship`
- `personality_cautious_weather_change`
- `personality_gossipy_rumor_heard`
- `personality_curious_story_finished`

## Interaction Rules

`SecondWorldEngine.InteractionResult` now exposes compatible fields:

- `personalityTags`
- `interactionPreference`
- `interactionWillingness`
- `preferredTopics`
- `avoidedTopics`

Examples:

- `outgoing`: higher willingness, prefers `talk` and `invite_coffee`.
- `introverted`: lower willingness, prefers `observe` and `short_talk`.
- `gossipy`: prefers `ask_about_rumor`.
- `kind`: prefers `help_work` and `comfort`.
- `competitive`: prefers `discuss_task` and `compare_progress`.
- `playful`: prefers `joke` and `office_humor`.

Pages should only read these fields and must not calculate personality.

## Dialogue, Story, Rumor, And Event Integration

Dialogue:

- `ResidentDialogueConditions` supports `personalityTags` and `excludedPersonalityTags`.
- `DialogueRuntimeManager` filters and slightly boosts matching personality dialogue.
- Safe fallback remains active.

Story:

- `ResidentStoryConditions` supports `personalityTags` and `excludedPersonalityTags`.
- `StoryRuntimeManager` boosts stories whose tags match personality preferences.
- General stories remain available when conditions allow.

Rumor:

- `RumorRuntimeManager` includes personality tags and rumor preference in resident rumor context.
- `gossipy`, `curious`, `serious`, `kind`, `introverted`, and `cautious` influence rumor ordering only.

Dynamic Event:

- `DynamicEventConditions` supports `personalityTags` and `excludedPersonalityTags`.
- `DynamicEventRuntimeManager` includes normalized personality and reaction tags in event context.
- Events still also evaluate weather, festival, location, relationship, story, rumor, fish, and achievement context.

## Emotion And Relationship Coordination

Personality influences emotion intensity and recovery indirectly through existing decision reasons.

- `optimistic` softens storm mood changes.
- `cautious` explains stronger storm avoidance.
- `playful` can bias toward lighter office humor.
- No per-tick random mood changes were added.

`RelationshipRuntimeManager` now applies only small personality deltas:

- Shared traits may add a small affinity.
- `kind` may soften relationship changes.
- Matching interaction style may add a small positive signal.
- No fixed personality conflict table was added.

Relationship reasons include:

- `personality_affinity`
- `personality_difference`
- `shared_interest`
- `interaction_style_match`
- `interaction_style_conflict`

## Save Compatibility

Personality base data remains in resident config and is not duplicated in saves.

`WorldSaveManager` now stores limited derived state per resident:

- `recentPersonalityInfluences`
- `lastPersonalityDecisionReason`
- `interactionPreferenceOverride`
- `overrideExpiresAt`

Old v1.0.0 saves without these fields load safely.

## Test Results

Local test coverage added:

- 100 residents return valid `ResidentPersonalityContext`.
- Unknown personality falls back to `calm`.
- Outgoing residents prefer social locations.
- Introverted residents prefer quiet locations.
- Hardworking residents are more likely to overtime.
- Lazy residents avoid overtime.
- Cautious residents avoid outdoor behavior during storm weather.
- Gossipy, serious, kind, introverted, and playful dialogue paths differ.
- Curious stories are prioritized without blocking general stories.
- Playful dynamic events become available.
- Rumor context includes personality attitude.
- Relationship changes include personality reason tags.
- Interaction results expose personality fields.
- Save data includes derived personality state.
- Legacy save state remains compatible.

Validation commands:

- `dart format lib test`: PASS
- `flutter analyze`: PASS
- `flutter test`: PASS
- `flutter build web --release`: PASS

## Performance Results

The 100-resident `ResidentPersonalityContext` batch generation smoke test is under 250 ms locally.

Context generation is cached in `ResidentRuntimeManager`, so dialogue, story, event, rumor, decision, and relationship runtimes do not parse resident personality independently.

## Known Limits

- Personality rules are still deterministic and lightweight; no simulation of deep psychology was added.
- Location display names and personality display names are not externalized to JSON in this feature.
- Rumor spread count itself is not personality-driven yet; only resident rumor ordering and tags are affected.
- Existing content JSON does not yet include broad `personalityTags`; the runtime is ready for future content packs.

## Next Step

Recommended next feature: Feature 04 Career & Promotion Integration.

Focus:

- Let office role, title, and work history influence resident schedules and story hooks.
- Keep all career signals data-driven.
- Do not add a new top-level manager unless a real cross-system ownership boundary appears.
