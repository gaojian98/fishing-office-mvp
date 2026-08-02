# Feature 06 Office Social & Friendship Integration Report

## FriendshipState Model

- Added lightweight `FriendshipState` and `FriendshipChangeRecord`.
- Friendship stays inside existing Relationship and Save paths.
- No top-level Social/Friendship Manager, Engine, or Repository was added.

## Friendship Stages

- `stranger`: score `0..9`
- `acquaintance`: score `10..24`
- `familiar`: score `25..44`
- `friend`: score `45..64`
- `close_friend`: score `65..84`
- `trusted_friend`: score `85..100`

Single interactions are capped to prevent jumping more than one stage.

## Trust And Familiarity

- `familiarity` can grow from repeated daily interaction.
- `trust` grows from more meaningful sources such as stories, help, work support, or conflict resolution.
- `trusted_friend` requires both high score and minimum trust/familiarity.

## Interaction Rules

- Ordinary interaction is small and source-deduped.
- Story interaction can give a larger but bounded increase.
- Dynamic events can provide explicit `friendshipChanges`.
- Same `sourceType + sourceId + residentId` cannot be settled twice.

## Personality And Emotion Influence

- Personality adjusts interaction weight and delta gently.
- `kind`, `outgoing`, `serious`, `playful`, `introverted`, and `cautious` affect willingness or gain size.
- Mood affects only the current interaction; negative mood does not permanently damage friendship by itself.

## Location Integration

- Office and world locations influence available interaction types.
- Pantry/coffee shop favor coffee or breaks.
- Work locations favor `help_work`.
- Balcony and break locations favor companionship/comfort.

## Skill Integration

- `communication` can mildly improve social gains.
- `observation` helps comfort/rumor familiarity.
- `management` helps work collaboration trust.
- Skill effects are capped and do not bypass friendship stages.

## Dialogue And Story Integration

- Dialogue conditions now support friendship stage, score, trust, familiarity, shared topics, last interaction type, and conflict flags.
- Story conditions now support minimum friendship stage, minimum trust/familiarity, required shared topic, recent interaction type, and conflict resolved checks.
- Old JSON remains valid because new fields default to safe empty values.

## Rumor And Event Integration

- Dynamic Event context includes friendship stages, tags, maximum trust, and maximum familiarity.
- Dynamic Event results support `friendshipChanges`.
- Rumor remains Provider-order compatible and can be influenced downstream through friendship tags and runtime context.

## Conflict And Recovery

- Conflict states: `none`, `minor_tension`, `conflict`, `recovering`.
- Conflict is temporary and recoverable through apology, help, shared events, and time.
- No enemy, dating, family, office politics, or faction system was added.

## Cooldown

- Social cooldowns use World Clock day count.
- Cooldowns persist through World Save.
- Refreshing the page does not reset cooldowns.

## Save Compatibility

- Added save fields: `friendshipStates`, `processedSocialSourceIds`, `socialInteractionHistory`, `socialCooldowns`, `conflictStates`, `dailySocialSummary`.
- Old saves with no friendship fields load safely.
- Missing FriendshipState can migrate from existing relationship records on first access.

## Testing

- `dart format` PASS for modified Dart files and smoke test.
- `flutter test test/framework_smoke_test.dart` PASS, 40 tests.
- `flutter analyze` PASS.
- `flutter test` PASS, 44 tests.
- `flutter build web --release` PASS.

## Performance

- Player-resident FriendshipState is created lazily on read or interaction.
- No new all-resident pairwise friendship graph was added.
- Daily social summary is generated during existing relationship daily update.

## Known Limits

- No social UI is included.
- Rumor runtime does not directly depend on FriendshipState to avoid Provider cycles.
- Existing resident-resident relationship daily update remains an older broad pass and was not expanded by this feature.

## Next Step

Recommend Feature 07: Office Group & Social Events Integration.
