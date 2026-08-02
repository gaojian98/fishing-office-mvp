# Browser Acceptance Test Plan

## Scope

- Version: `v1.2.0-rc.1`
- Branch: `feature/v1.1-office-life-schedule`
- Local URL: `http://127.0.0.1:3101/#/home`
- Browser: Codex in-app Chrome bridge
- Date: 2026-08-03 UTC+07

## Preconditions

- Use the repository root server: `PORT=3101 node server.js`.
- Use the Flutter release build under `fishing_office_flutter/build/web`.
- Do not deploy Railway during this plan.
- Do not commit, push, tag, or merge during this plan.

## Entry Points

| Entry | Expected Result |
| --- | --- |
| Profile | Opens Profile Center and can return to home interactions. |
| Game Help | Opens guide dialog and can return to home interactions. |
| Exit | Opens exit confirmation and can return to home interactions. |
| Store | Opens store dialog and can return to home interactions. |
| Honor | Opens honor dialog and can return to home interactions. |
| Inventory | Opens bag dialog and can return to home interactions. |
| Start Fishing | Enters fishing flow. |
| Today Task | Opens task dialog and can return to home interactions. |
| Fish Collection | Opens collection dialog and can return to home interactions. |

## Core Flow

1. Open home.
2. Click Start Fishing.
3. Wait for fishing state and waiting events.
4. Click pull-line result action.
5. Verify fish result appears.
6. Verify Sell changes screen state.
7. Verify Put Into Bag changes screen state.
8. Verify Console error count remains zero.

## Resource Checks

- `/`
- `/flutter_bootstrap.js`
- `/main.dart.js`
- `/manifest.json`
- `/assets/assets/config/resident_dialogue.json`
- `/assets/assets/config/office_dialog.json`
- `/assets/assets/config/dialog.json`

`dialog.json` must not be requested by the app. Direct manual request should return a missing static asset response, not HTML fallback.

## Responsive Checks

- Browser automation verified the current plugin viewport.
- Target mobile sizes remain covered by Widget tests because the Chrome bridge did not expose viewport control.

## Exit Criteria

- 9 entry points open.
- Close or return releases pointer handling.
- Core fishing path opens result.
- Console errors: 0.
- Critical network resources: PASS.
- Missing static JSON does not fallback to `index.html`.
