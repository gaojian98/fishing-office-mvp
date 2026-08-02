# v1.2.0 RC1 Commit Plan

Branch: `feature/v1.1-office-life-schedule`
Base HEAD: `1bbd884`

No commit is authorized by this document. It is a staging handoff plan only.

## Dependency Order

1. Runtime models and runtime integration.
2. Interactive office UI wiring that consumes the runtime state.
3. JSON content integration required by the runtime and UI surfaces.
4. Static fallback / deployment safety fix.
5. Test coverage for the integrated RC behavior.
6. Documentation, release package, and authorization-gate files.

## Proposed Commits

### Commit 1: `feat(runtime): integrate v1.1 office world simulation`

File count: 33

- `fishing_office_flutter/lib/core/dialog/dialog_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/core/managers/achievement_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/managers/daily_simulation_manager.dart`
- `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/economy_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/fish_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/quest_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_decision_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_life_manager.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/rumor_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_tick_manager.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/lib/models/career_state.dart`
- `fishing_office_flutter/lib/models/dynamic_event_config.dart`
- `fishing_office_flutter/lib/models/friendship_state.dart`
- `fishing_office_flutter/lib/models/interactive_office.dart`
- `fishing_office_flutter/lib/models/living_office_state.dart`
- `fishing_office_flutter/lib/models/location_context.dart`
- `fishing_office_flutter/lib/models/office_group.dart`
- `fishing_office_flutter/lib/models/office_life_schedule.dart`
- `fishing_office_flutter/lib/models/player_influence.dart`
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart`
- `fishing_office_flutter/lib/models/resident_personality_context.dart`
- `fishing_office_flutter/lib/models/resident_story_config.dart`
- `fishing_office_flutter/lib/models/rumor_config.dart`
- `fishing_office_flutter/lib/models/world_save_data.dart`

### Commit 2: `feat(office): add interactive office hub and resident actions`

File count: 2

- `fishing_office_flutter/lib/pages/profile/profile_center_dialog_page.dart`
- `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart`

### Commit 3: `feat(content): integrate office dialogue story rumor and events`

File count: 5

- `fishing_office_flutter/assets/config/event.json`
- `fishing_office_flutter/assets/config/events.json`
- `fishing_office_flutter/assets/config/resident_dialogue.json`
- `fishing_office_flutter/assets/config/resident_story.json`
- `fishing_office_flutter/assets/config/rumor.json`

### Commit 4: `fix(release): stabilize static asset fallback and interaction safety`

File count: 1

- `server.js`

### Commit 5: `test(rc): add release candidate acceptance coverage`

File count: 4

- `fishing_office_flutter/test/content_integration_test.dart`
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/release_candidate_integration_test.dart`
- `fishing_office_flutter/test/widgets/resident_detail_dialog_test.dart`

### Commit 6: `docs(release): prepare v1.2.0 release candidate handoff`

File count: 143

- `00_Project/Module_Manifests/Achievement.md`
- `00_Project/Module_Manifests/Dialogue.md`
- `00_Project/Module_Manifests/Dynamic_Event.md`
- `00_Project/Module_Manifests/Economy.md`
- `00_Project/Module_Manifests/Festival.md`
- `00_Project/Module_Manifests/Fish.md`
- `00_Project/Module_Manifests/Location.md`
- `00_Project/Module_Manifests/Personality.md`
- `00_Project/Module_Manifests/Quest.md`
- `00_Project/Module_Manifests/Relationship.md`
- `00_Project/Module_Manifests/Resident.md`
- `00_Project/Module_Manifests/Rumor.md`
- `00_Project/Module_Manifests/Save.md`
- `00_Project/Module_Manifests/Second_World.md`
- `00_Project/Module_Manifests/Story.md`
- `00_Project/Module_Manifests/Weather.md`
- `00_Project/Module_Manifests/World_Tick.md`
- `00_Project/Module_Manifests/achievement_runtime.md`
- `00_Project/Module_Manifests/career_runtime.md`
- `00_Project/Module_Manifests/daily_simulation.md`
- `00_Project/Module_Manifests/dialogue_runtime.md`
- `00_Project/Module_Manifests/dynamic_event_runtime.md`
- `00_Project/Module_Manifests/economy_runtime.md`
- `00_Project/Module_Manifests/festival_runtime.md`
- `00_Project/Module_Manifests/fish_runtime.md`
- `00_Project/Module_Manifests/interactive_office.md`
- `00_Project/Module_Manifests/inventory_runtime.md`
- `00_Project/Module_Manifests/living_office_world.md`
- `00_Project/Module_Manifests/memory_runtime.md`
- `00_Project/Module_Manifests/office_group_runtime.md`
- `00_Project/Module_Manifests/player_influence.md`
- `00_Project/Module_Manifests/quest_runtime.md`
- `00_Project/Module_Manifests/relationship_runtime.md`
- `00_Project/Module_Manifests/resident_emotion.md`
- `00_Project/Module_Manifests/resident_interaction.md`
- `00_Project/Module_Manifests/resident_location.md`
- `00_Project/Module_Manifests/resident_personality.md`
- `00_Project/Module_Manifests/resident_runtime.md`
- `00_Project/Module_Manifests/resident_schedule.md`
- `00_Project/Module_Manifests/rumor_runtime.md`
- `00_Project/Module_Manifests/save_system.md`
- `00_Project/Module_Manifests/second_world_engine.md`
- `00_Project/Module_Manifests/skill_runtime.md`
- `00_Project/Module_Manifests/social_runtime.md`
- `00_Project/Module_Manifests/story_runtime.md`
- `00_Project/Module_Manifests/weather_runtime.md`
- `00_Project/Module_Manifests/world_clock.md`
- `00_Project/Module_Manifests/world_context.md`
- `00_Project/PROJECT_INDEX.md`
- `00_Project/v1.1.0/CURRENT_STATE.md`
- `00_Project/v1.1.0/Feature_01_Office_Life_Schedule_Report.md`
- `00_Project/v1.1.0/Feature_02_Office_Locations_Report.md`
- `00_Project/v1.1.0/Feature_03_Resident_Personality_Report.md`
- `00_Project/v1.1.0/Feature_04_Career_Promotion_Report.md`
- `00_Project/v1.1.0/Feature_04_Context_Plan.md`
- `00_Project/v1.1.0/Feature_05_Skills_Career_Feedback_Report.md`
- `00_Project/v1.1.0/Feature_06_Office_Social_Friendship_Report.md`
- `00_Project/v1.1.0/Feature_07_Office_Group_Report.md`
- `00_Project/v1.1.0/Feature_08_Living_Office_World_Report.md`
- `00_Project/v1.1.0/Feature_09_Player_Influence_Report.md`
- `00_Project/v1.1.0_Roadmap.md`
- `00_Project/v1.2.0/Accessibility_Report.md`
- `00_Project/v1.2.0/Browser_Acceptance_Final_Report.md`
- `00_Project/v1.2.0/Browser_Acceptance_Test_Plan.md`
- `00_Project/v1.2.0/Browser_Console_Report.md`
- `00_Project/v1.2.0/Browser_Network_Report.md`
- `00_Project/v1.2.0/Browser_Stability_Report.md`
- `00_Project/v1.2.0/CURRENT_STATE.md`
- `00_Project/v1.2.0/Content_Coverage_Report.md`
- `00_Project/v1.2.0/Content_Integration_Architecture.md`
- `00_Project/v1.2.0/Content_Integration_Final_Report.md`
- `00_Project/v1.2.0/Content_Integration_Performance_Report.md`
- `00_Project/v1.2.0/Content_Integration_Test_Report.md`
- `00_Project/v1.2.0/Content_Quality_Report.md`
- `00_Project/v1.2.0/Dialogue_Content_Report.md`
- `00_Project/v1.2.0/Event_Content_Report.md`
- `00_Project/v1.2.0/Interaction_Content_Report.md`
- `00_Project/v1.2.0/Interactive_Office_Life_Architecture.md`
- `00_Project/v1.2.0/Interactive_Office_Life_Compatibility_Report.md`
- `00_Project/v1.2.0/Interactive_Office_Life_Final_Report.md`
- `00_Project/v1.2.0/Interactive_Office_Life_Performance_Report.md`
- `00_Project/v1.2.0/Interactive_Office_Life_Test_Report.md`
- `00_Project/v1.2.0/Interactive_Office_Life_UI_Map.md`
- `00_Project/v1.2.0/Manual_Product_Flow_Report.md`
- `00_Project/v1.2.0/Product_Experience_Map.md`
- `00_Project/v1.2.0/QA_Compatibility_Report.md`
- `00_Project/v1.2.0/QA_Final_Report.md`
- `00_Project/v1.2.0/QA_Known_Issues.md`
- `00_Project/v1.2.0/QA_Performance_Report.md`
- `00_Project/v1.2.0/QA_Stability_Test_Plan.md`
- `00_Project/v1.2.0/QA_Stability_Test_Report.md`
- `00_Project/v1.2.0/RC_Commit_Scope_Report.md`
- `00_Project/v1.2.0/RC_Final_Acceptance_Report.md`
- `00_Project/v1.2.0/RC_Integration_Test_Plan.md`
- `00_Project/v1.2.0/RC_Integration_Test_Report.md`
- `00_Project/v1.2.0/RC_Known_Issues.md`
- `00_Project/v1.2.0/RC_Long_Run_Report.md`
- `00_Project/v1.2.0/RC_Performance_Report.md`
- `00_Project/v1.2.0/RC_Release_Checklist.md`
- `00_Project/v1.2.0/RC_Save_Compatibility_Report.md`
- `00_Project/v1.2.0/RC_Security_Checklist.md`
- `00_Project/v1.2.0/RC_Transaction_Safety_Report.md`
- `00_Project/v1.2.0/RC_Web_Resource_Report.md`
- `00_Project/v1.2.0/Release_Package/AUTHORIZATION_CHECKLIST.md`
- `00_Project/v1.2.0/Release_Package/AUTHORIZED_COMMANDS.md`
- `00_Project/v1.2.0/Release_Package/COMMIT_AUTHORIZATION_GATE.md`
- `00_Project/v1.2.0/Release_Package/COMMIT_COVERAGE_REPORT.md`
- `00_Project/v1.2.0/Release_Package/COMMIT_PLAN.md`
- `00_Project/v1.2.0/Release_Package/DOCUMENT_RETENTION_REVIEW.md`
- `00_Project/v1.2.0/Release_Package/FILE_CHANGE_MANIFEST.md`
- `00_Project/v1.2.0/Release_Package/HIGH_RISK_FILES.md`
- `00_Project/v1.2.0/Release_Package/JSON_CHANGE_REVIEW.md`
- `00_Project/v1.2.0/Release_Package/KNOWN_ISSUES.md`
- `00_Project/v1.2.0/Release_Package/MANUAL_ACCEPTANCE.md`
- `00_Project/v1.2.0/Release_Package/MANUAL_BROWSER_ACCEPTANCE.md`
- `00_Project/v1.2.0/Release_Package/MANUAL_DIFF_REVIEW.md`
- `00_Project/v1.2.0/Release_Package/RELEASE_MANIFEST.md`
- `00_Project/v1.2.0/Release_Package/ROLLBACK_PLAN.md`
- `00_Project/v1.2.0/Release_Package/STAGING_HANDOFF.md`
- `00_Project/v1.2.0/Release_Package/TEST_SUMMARY.md`
- `00_Project/v1.2.0/Release_Packaging_Final_Report.md`
- `00_Project/v1.2.0/Resident_Detail_Interaction_Architecture.md`
- `00_Project/v1.2.0/Resident_Detail_Interaction_Final_Report.md`
- `00_Project/v1.2.0/Resident_Detail_Interaction_Performance_Report.md`
- `00_Project/v1.2.0/Resident_Detail_Interaction_Test_Report.md`
- `00_Project/v1.2.0/Resident_Detail_Interaction_UI_Map.md`
- `00_Project/v1.2.0/Responsive_Browser_Report.md`
- `00_Project/v1.2.0/Responsive_Layout_Report.md`
- `00_Project/v1.2.0/Rumor_Content_Report.md`
- `00_Project/v1.2.0/Staging_Configuration_Audit.md`
- `00_Project/v1.2.0/Staging_Deployment_Plan.md`
- `00_Project/v1.2.0/Story_Content_Report.md`
- `00_Project/v1.2.0/Visual_Design_Standard.md`
- `00_Project/v1.2.0/Visual_Polish_Final_Report.md`
- `00_Project/v1.2.0/Visual_Polish_Known_Issues.md`
- `00_Project/v1.2.0/Visual_Polish_Performance_Report.md`
- `00_Project/v1.2.0/Visual_Polish_Test_Report.md`
- `00_Project/v1.2.0/v1.2.0_RC1_Release_Notes.md`
- `00_Project/v1.2.0/v1.2.0_Roadmap.md`
- `AGENTS.md`
- `CHANGELOG.md`
- `README.md`
- `scripts/release/prepare_v1_2_rc_commits.sh`

## Inseparable Changes

- Runtime model additions and manager changes should be reviewed together because public interfaces and save compatibility fields cross-reference each other.
- Resident detail / office hub UI changes should stay with their widget tests.
- JSON content changes should stay together to preserve references among events, dialogue, stories, and rumors.
- `server.js` should stay isolated because it is a deployment/static fallback safety fix.
- Release package documentation and the prepare script should stay together as the handoff bundle.
