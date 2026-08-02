# v1.2.0 RC Integration Test Plan

## Scope

Release Candidate: `v1.2.0-rc.1`
Date: 2026-08-02 22:15:42 UTC+07:00
Branch: `feature/v1.1-office-life-schedule`

## Modules Under Test

- v1.1.0 Feature 01-09
- v1.2.0 Module 01 Interactive Office Life
- v1.2.0 Module 02 Resident Detail Interaction
- v1.2.0 Module 03 QA & Stability Sprint
- v1.2.0 Module 04 Content Integration & Interaction Expansion
- v1.2.0 Module 05 Visual Polish & Product Experience
- v1.2.0 Module 06 Release Candidate Integration & Final Acceptance

## Automated Coverage

- Full office interaction flow through existing smoke and widget tests.
- Core fishing flow through existing smoke tests.
- Save, legacy save, and damaged save fallback through `release_candidate_integration_test.dart`.
- Duplicate request and duplicate settlement state through existing smoke tests and RC serialization tests.
- Overlay and pointer safety through Office Hub widget tests and home hotspot tests.
- Critical asset path and JSON parsing through RC tests and HTTP checks.
- Responsive critical flow through Office Hub widget tests.

## Manual Coverage Still Required

- Real browser Console inspection.
- Real browser pointer validation across all homepage buttons.
- Product owner flow acceptance before Commit / Push / Tag / Staging deployment.
