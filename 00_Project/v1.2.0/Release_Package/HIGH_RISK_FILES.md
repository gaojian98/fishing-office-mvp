# High Risk Files Review

Date: 2026-08-03
Branch: `feature/v1.1-office-life-schedule`

| Path | Risk | Why manual review is needed | Review focus | Suggested conclusion |
|---|---|---|---|---|
| `00_Project/v1.2.0/Release_Package/AUTHORIZED_COMMANDS.md` | MEDIUM | Docs file in `docs-release-package` is release-critical. | authorization language and no accidental commit/push permission. | REVIEW THEN KEEP |
| `00_Project/v1.2.0/Release_Package/COMMIT_AUTHORIZATION_GATE.md` | MEDIUM | Docs file in `docs-release-package` is release-critical. | authorization language and no accidental commit/push permission. | REVIEW THEN KEEP |
| `00_Project/v1.2.0/Release_Package/COMMIT_PLAN.md` | MEDIUM | Docs file in `docs-release-package` is release-critical. | authorization language and no accidental commit/push permission. | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/event.json` | MEDIUM | JSON file in `content-json` is release-critical. | content count, ids, tone, and runtime references. | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/events.json` | MEDIUM | JSON file in `content-json` is release-critical. | content count, ids, tone, and runtime references. | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/resident_dialogue.json` | MEDIUM | JSON file in `content-json` is release-critical. | content count, ids, tone, and runtime references. | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/resident_story.json` | MEDIUM | JSON file in `content-json` is release-critical. | content count, ids, tone, and runtime references. | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/rumor.json` | MEDIUM | JSON file in `content-json` is release-critical. | content count, ids, tone, and runtime references. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/engine/second_world_engine.dart` | HIGH | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/achievement_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/dialogue_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/dynamic_event_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/economy_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/quest_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/resident_decision_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/story_runtime_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/world_save_manager.dart` | HIGH | Dart file in `runtime-code` is release-critical. | save compatibility and public interface. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/managers/world_tick_manager.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/core/providers/app_providers.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/career_state.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/friendship_state.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/interactive_office.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/living_office_state.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/office_group.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/player_influence.dart` | MEDIUM | Dart file in `runtime-code` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/models/world_save_data.dart` | HIGH | Dart file in `runtime-code` is release-critical. | save compatibility and public interface. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/pages/profile/profile_center_dialog_page.dart` | MEDIUM | Dart file in `interactive-ui` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart` | MEDIUM | Dart file in `interactive-ui` is release-critical. | runtime behavior and integration boundaries. | REVIEW THEN KEEP |
| `fishing_office_flutter/test/content_integration_test.dart` | MEDIUM | Dart file in `tests` is release-critical. | assertions were added without reducing prior coverage. | REVIEW THEN KEEP |
| `fishing_office_flutter/test/framework_smoke_test.dart` | MEDIUM | Dart file in `tests` is release-critical. | assertions were added without reducing prior coverage. | REVIEW THEN KEEP |
| `fishing_office_flutter/test/release_candidate_integration_test.dart` | MEDIUM | Dart file in `tests` is release-critical. | assertions were added without reducing prior coverage. | REVIEW THEN KEEP |
| `server.js` | MEDIUM | Deploy file in `static-runtime-fallback` is release-critical. | missing static resources return 404 and SPA fallback still works. | REVIEW THEN KEEP |
