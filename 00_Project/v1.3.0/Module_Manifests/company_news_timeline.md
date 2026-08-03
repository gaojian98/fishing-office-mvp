# company_news_timeline

## Purpose
Project organization, career, economy, AI decision, event, and achievement changes into player-readable company news and structured timeline history.

## Main files
- `fishing_office_flutter/lib/models/living_office_state.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/models/world_save_data.dart`

## Data files
- Runtime save state only.
- No new JSON type.

## Public interfaces
- `CompanyNewsItem`
- `CompanyTimelineEvent`
- `CompanyTimelineSnapshot`
- `WorldSaveManager.recordCompanyTimelineEvent(...)`
- `WorldSaveManager.getCompanyTimelineSnapshot(...)`
- `WorldSaveManager.companyNews`
- `WorldSaveManager.companyTimeline`
- `SecondWorldEngine.recordCompanyTimelineEvent(...)`
- `SecondWorldEngine.getCompanyTimelineSnapshot(...)`

## Direct dependencies
- Living Office State
- World Save
- Second World Engine
- Career
- Office Economy
- AI Decision
- Achievement
- Dynamic Event

## Consumers
- Future UI timeline/news panels
- Daily Summary
- Future AI Company Events
- Product validation reports

## Save fields
- `companyNews`
- `companyTimeline`

## Invariants
- News is a readable projection, not the source of business truth.
- Timeline is structured history, not the source of business truth.
- Stable `sourceId` prevents duplicate news/timeline records.
- History is bounded: 120 news items and 240 timeline events.
- UI must read `CompanyTimelineSnapshot` instead of scanning all runtimes.
- Old saves without news/timeline fields load empty.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- News text uses engineering templates until product copy is supplied.
- No dedicated timeline UI is included in this module.
- Timeline is explicitly recorded by runtime callers; automatic event harvesting is deferred to Module 08.
