# v1.2.0 Module 04 Content Integration & Interaction Expansion

Date: 2026-08-02
Branch: feature/v1.1-office-life-schedule

## Scope
Content integration only. No new top-level Manager, Engine, Repository, Runtime, page, JSON type, commit, push, deploy, or v1.0.0 release change.

## Content Totals
- Residents: 100
- Dialogue entries: 2620
- Interaction feedback entries: 160
- Resident stories: 1320
- Rumors: 300
- Dynamic events: 120
- Events with actions: 120
- Weather entries: 100
- Festival entries: 50
- Fish entries: 90

## Rumor Changes
- Retained 300 rumors.
- Added compatible fields: summary, sourceType, truthState, heat, locationTags, residentTags, timeRestrictions, weatherTags, festivalTags, storyTags, spreadRules, expireRules.
- Rumor entries remain readable through existing `RumorConfig` and existing runtime APIs.

## Interaction
`ask_about_rumor`, `share_rumor`, and `verify_rumor` now leave resident memory and activate the selected rumor through Rumor Runtime.
