# Gold Master Revalidation Report

Version: v1.0.0
Production URL: https://fishing.up.railway.app/
Online commit: b8312d5d7fb41f451b728f15247fc14a1c18290b
Railway deployment ID: not available from local CLI/session
Test date: 2026-08-02

## Test Environment

- Browser: Codex in-app browser
- Production host: Railway
- Desktop viewport: 1280 x 720
- Mobile viewports: 360 x 800, 390 x 844, 412 x 915
- Baseline viewport: 1080 x 1920

## Production Resource Check

- `/`: PASS, HTTP 200
- `/flutter_bootstrap.js`: PASS, HTTP 200
- `/main.dart.js`: PASS, HTTP 200
- `/manifest.json`: PASS, HTTP 200
- `/assets/assets/config/office_dialog.json`: PASS, JSON 200
- `/assets/assets/config/resident_dialogue.json`: PASS, JSON 200
- `/assets/assets/config/fish_collection.json`: PASS, JSON 200
- `main.dart.js` references `office_dialog.json`: PASS
- `main.dart.js` references `resident_dialogue.json`: PASS
- `main.dart.js` references `fish_collection.json`: PASS
- `main.dart.js` references `assets/config/dialog.json`: PASS, not found

## Home Entry Regression

Real browser clicks were tested using the frozen 1080 x 1920 hotspot coordinates and Flutter proportional scaling.

| Entry | Desktop 1280x720 | 360x800 | 390x844 | 412x915 | 1080x1920 |
| --- | --- | --- | --- | --- | --- |
| Avatar / Profile | PASS | PASS | PASS | PASS | PASS |
| Game Guide | PASS | PASS | PASS | PASS | PASS |
| Exit | PASS | PASS | PASS | PASS | PASS |
| Store | PASS | PASS | PASS | PASS | PASS |
| Honor | PASS | PASS | PASS | PASS | PASS |
| Inventory | PASS | PASS | PASS | PASS | PASS |
| Start Fishing | PASS | PASS | PASS | PASS | PASS |
| Daily Tasks | PASS | PASS | PASS | PASS | PASS |
| Collection | PASS | PASS | PASS | PASS | PASS |

Result: all 9 home entries are clickable after the hotfix.

## Popup Interaction Regression

Validated on 390 x 844 unless noted.

- Profile: PASS, opens and closes; home remains clickable.
- Exit: PASS, opens and closes; home remains clickable.
- Store: PASS, opens and closes; home remains clickable.
- Honor: PASS, opens and closes; home remains clickable.
- Inventory: PASS, opens and closes; home remains clickable.
- Daily Tasks: PASS, opens and closes; home remains clickable.
- Store repeated open/close 10 times: PASS.
- Game Guide: NEEDS FIX, opens but close control is not reliably visible/reachable at 390 x 844 in automated validation.
- Collection: PASS after production redeploy, opens with title, stats, category sidebar, fish detail content, footer controls, and visible close control.

## Core Fishing Result

One production flow was executed after the home interaction hotfix:

Home -> Start Fishing -> Waiting -> Can Pull Line -> Pull Line -> Catch Result -> Put Into Bag -> Return Home -> Store probe.

Result:

- Start fishing: PASS
- Waiting state: PASS
- Waiting text: PASS
- Pull line availability: PASS
- Catch result popup: PASS
- Put into bag confirmation: PASS
- Return to home and click another entry: PASS
- Console errors: 0

One production fishing loop was rerun after the `GM-RV-001` deployment and passed through catch result and put-into-bag confirmation. The broader 10-round final acceptance loop remains a product-owner manual acceptance item before Pack 33.

## Second World Result

Not fully revalidated in this run.

Pack 32 hotfix scope was rerun after `GM-RV-001` deployment. Home entries, Collection popup, critical resources, and a core fishing loop passed. Full second-world long-form acceptance remains covered by the existing GM report and future final release check.

## Save Result

Partial validation only:

- Fish result -> put into bag confirmation: PASS
- Return to home after fish result: PASS
- Home remains clickable after fish result: PASS

Full save/restart recovery was not rerun in this targeted Pack 32 hotfix pass. Fish result -> put into bag -> inventory probe passed without duplicate reward or console error.

## Performance Result

Observed during online validation:

- Home initial load: PASS, page rendered and accepted clicks after load.
- Home clickable time: PASS in all tested viewports.
- Store repeated open/close 10 times: PASS, no visible click loss.
- Console errors: 0
- No obvious click-fix-related performance regression observed.

## Issue List

| ID | Severity | Module | Description | Status |
| --- | --- | --- | --- | --- |
| GM-RV-001 | P1 | Collection | Fish Collection / 图鉴 popup opened as an empty panel on desktop and mobile because its nested layout was not converted into LayoutElement entries. | Fixed and verified in production |
| GM-RV-002 | P2 | Game Guide | Guide popup opens, but close control is not reliably visible/reachable at 390 x 844 automated validation. | Open |

## P0 / P1 Count

- P0: 0
- P1: 0 after production `GM-RV-001` verification

## Recommendation

Production hotfix validation for `GM-RV-001` satisfies the immediate P1 fix requirement.

Do not create a new tag.
Do not re-freeze v1.0.0 until the product owner explicitly approves Pack 33.

Next recommended action: product owner reviews this Pack 32 result, then explicitly decides whether to proceed with Pack 33.

## GM-RV-001 Local Fix Addendum

Date: 2026-08-02
Local validation URL: http://127.0.0.1:3102/#/home

Root cause:

- `FishCollectionDialogPage` looked up `collection_header`, `collection_close`, `collection_stats`, and other `LayoutElement` IDs.
- The `fish_collection` layout in `office_layout.json` is a nested object, not an `elements` list.
- `LayoutConfig.fromJson` only parsed `elements`, so all internal collection rects were missing and the dialog rendered as an empty panel.
- After adding nested Fish Collection layout normalization, content rendered, but mobile sizing was still too large because the page used the global responsive scale instead of the collection layout design size.

Fix:

- `LayoutConfig.fromJson` now preserves normal `elements` parsing and additionally maps the nested Fish Collection layout into the expected `collection_*` element IDs.
- `FishCollectionDialogPage` now computes scale from `layout.designSize` and the current viewport.
- A regression test verifies the nested Fish Collection layout exposes the required dialog element IDs.

Local Pack 32 rerun:

- Home entry regression on 1280 x 720, 360 x 800, 390 x 844, 412 x 915, and 1080 x 1920: PASS.
- Collection opens with visible content on desktop local release build: PASS.
- Collection opens with visible content on mobile local release build: PASS.
- Collection close button works on desktop local release build: PASS.
- Collection close button works on mobile local release build: PASS.
- Console errors during local Collection validation: 0.
- Core fishing flow to catch result in local release build: PASS.

Build validation:

- `flutter analyze`: PASS.
- `flutter test`: PASS, 38 tests.
- `flutter build web --release`: PASS.

Production status:

- Redeployed with the `GM-RV-001` fix.
- Production Pack 32 targeted verification passed for `GM-RV-001`, 9 home entries, critical resources, and one core fishing loop.

## GM-RV-001 Production Verification Addendum

Date: 2026-08-02
Production URL: https://fishing.up.railway.app/
Production commit: b8312d5d7fb41f451b728f15247fc14a1c18290b

Deployment:

- `git push origin main`: PASS.
- Production `/main.dart.js` includes the `collection_header` fix marker: PASS.
- Railway deployment ID: not available from local CLI/session.

Resource check:

- `/`: PASS, HTTP 200.
- `/flutter_bootstrap.js`: PASS, HTTP 200.
- `/main.dart.js`: PASS, HTTP 200.
- `/assets/assets/config/office_dialog.json`: PASS, JSON 200.
- `/assets/assets/config/resident_dialogue.json`: PASS, JSON 200.
- `main.dart.js` references `assets/config/dialog.json`: PASS, 0 references.

Home entry check:

- Avatar / Profile: PASS.
- Game Guide: PASS.
- Exit: PASS.
- Store: PASS.
- Honor: PASS.
- Inventory: PASS.
- Start Fishing: PASS.
- Daily Tasks: PASS.
- Collection: PASS.
- Console errors during entry validation: 0.

Collection check:

- Collection opens: PASS.
- Collection renders title, stats, sidebar, fish preview, detail, story, and footer controls: PASS.
- Collection is no longer blank: PASS.
- Console errors during Collection validation: 0.

Core flow check:

- Start Fishing: PASS.
- Waiting state: PASS.
- Waiting events display: PASS.
- Can pull line: PASS.
- Catch result popup: PASS.
- Put into bag confirmation: PASS.
- Inventory probe after put into bag: PASS.
- Console errors during core flow: 0.

Current blocking result:

- P0: 0.
- P1: 0.
- P2: 1 known automated mobile guide-close reachability issue remains recorded for product-owner review.
