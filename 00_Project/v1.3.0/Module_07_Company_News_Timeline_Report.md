# Module 07 Company News & Timeline Report

## Status

IMPLEMENTED - WAITING FOR REVIEW

## Scope

Module 07 adds company news and structured company timeline projections.

No new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type is introduced.

## Implemented Models

`CompanyNewsItem`:

- `newsId`
- `sourceId`
- `type`
- `category`
- `title`
- `summary`
- `importance`
- `date`
- `relatedResidentIds`
- `tags`

`CompanyTimelineEvent`:

- `eventId`
- `sourceId`
- `type`
- `category`
- `title`
- `summary`
- `importance`
- `date`
- `weekKey`
- `monthKey`
- `relatedResidentIds`
- `tags`
- `payload`

`CompanyTimelineSnapshot`:

- `news`
- `events`
- `dailySummary`
- `weeklySummary`
- `monthlySummary`

## Runtime Behavior

`WorldSaveManager` now owns company news and timeline projections:

- `recordCompanyTimelineEvent(...)`
- `getCompanyTimelineSnapshot(...)`
- `companyNews`
- `companyTimeline`

`SecondWorldEngine` exposes facade methods for callers:

- `recordCompanyTimelineEvent(...)`
- `getCompanyTimelineSnapshot(...)`

## Rules

- News is readable projection only.
- Timeline is structured history only.
- Business state remains owned by Career, Organization Mutation, Office Economy, AI Decision, Dynamic Event, Quest, and Achievement.
- Duplicate `sourceId` returns the existing timeline event.
- News history is capped at 120 items.
- Timeline history is capped at 240 events.
- Old saves load empty news and timeline lists.

## Coverage

Smoke test covers:

- career news
- economy news
- AI decision news
- resident achievement news
- duplicate sourceId
- daily summary
- weekly summary
- monthly summary
- capacity limits
- Save / Restore
- old-save fallback
- Timeline Snapshot through `SecondWorldEngine`

## Known Limits

- Timeline records are explicit projections; automatic harvesting from every runtime is deferred to Module 08.
- News copy uses simple engineering-level text.
- No new UI is included.
