# social_runtime

## Purpose
Track player-resident friendship as a lightweight capability inside the existing Relationship runtime.

## Main files
- `fishing_office_flutter/lib/models/friendship_state.dart`
- `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart`
- `fishing_office_flutter/lib/models/resident_story_config.dart`
- `fishing_office_flutter/lib/models/dynamic_event_config.dart`

## Data files
- Runtime save only.
- No new JSON type.

## Public interfaces
- `WorldSaveManager.getFriendshipState(residentId)`
- `WorldSaveManager.recordFriendshipChange(...)`
- `WorldSaveManager.setSocialCooldown(...)`
- `WorldSaveManager.isSocialCooldownActive(residentId, interactionType)`
- `RelationshipRuntimeManager.getFriendshipState(residentId)`
- `RelationshipRuntimeManager.getAvailableInteractions(residentId)`
- `RelationshipRuntimeManager.applyFriendshipChange(...)`
- `SecondWorldEngine.getFriendshipState(residentId)`

## Direct dependencies
- Relationship
- Resident Runtime
- Location Context
- Personality Context
- Skill Runtime
- Story Runtime
- Rumor Runtime
- Save

## Consumers
- Second World Engine
- Dialogue Runtime
- Story Runtime
- Dynamic Event Runtime
- Future resident UI through existing providers

## Save fields
- `friendshipStates`
- `processedSocialSourceIds`
- `socialInteractionHistory`
- `socialCooldowns`
- `conflictStates`
- `dailySocialSummary`

## Invariants
- No `SocialManager`, `FriendshipManager`, `FriendshipEngine`, or `SocialRepository`.
- Score is bounded to `0..100`.
- Stages are `stranger`, `acquaintance`, `familiar`, `friend`, `close_friend`, `trusted_friend`.
- Trust and familiarity are separate; high familiarity does not imply high trust.
- Each change must have `sourceType`, `sourceId`, and `residentId`.
- Same source key cannot be settled twice.
- Ordinary interactions stay small; important stories and major events remain capped.
- Conflict is temporary and recoverable.
- Cooldowns use World Clock day count, not real system time.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- No social UI in Feature 06.
- Rumor runtime keeps Provider-order compatibility and consumes friendship indirectly through context tags and downstream runtime conditions.
- Resident-resident social graph remains intentionally shallow.
