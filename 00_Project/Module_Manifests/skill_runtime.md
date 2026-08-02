# skill_runtime

## Purpose
Track lightweight player skill growth as part of the existing career runtime, so career progress can explain what the player is getting better at without adding a separate skill system.

## Main files
- `fishing_office_flutter/lib/models/career_state.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/managers/quest_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/fish_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`

## Data files
- Runtime save state only.
- No new JSON type.

## Public interfaces
- `WorldSaveManager.playerSkillStates`
- `WorldSaveManager.getSkillState(skillId)`
- `WorldSaveManager.recordSkillExperience(...)`
- `WorldSaveManager.recordSkillExperienceBatch(...)`
- `SecondWorldEngine.getSkillState(skillId)`
- `SecondWorldEngine.getSkillSummary()`
- `SecondWorldEngine.recordSkillExperience(...)`

## Direct dependencies
- Career
- Quest
- Fish
- Relationship
- Daily Simulation
- Achievement
- Save

## Consumers
- Second World Engine
- Fish Runtime
- Quest Runtime
- Relationship Runtime
- Achievement Runtime
- Future profile/career UI through existing providers

## Save fields
- `playerSkillStates`
- `skillExperienceHistory`
- `processedSkillSourceIds`
- `careerFeedbackHistory`
- `latestCareerFeedback`

## Invariants
- No `SkillManager`, `SkillEngine`, or `SkillRepository`.
- Skills are player-only lightweight state.
- Skills never downgrade.
- Skill levels are bounded to `1..10`.
- Every skill gain requires `sourceType`, `sourceId`, `skillId`, and `amount`.
- `sourceType + sourceId + skillId` prevents duplicate skill experience.
- Skill effects are capped and cannot bypass fish rarity, task, relationship, or story conditions.
- UI may read skill state and feedback but must not mutate them directly.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Feature 05 does not add a skill page.
- Existing JSON content is not expanded with skill tasks.
- Skill labels remain engineering identifiers until product copy is provided.
