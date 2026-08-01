# Home Interaction Hotfix Report

## Hotfix

- Task: Production Hotfix 02 - Home Interaction Validation & Redeployment
- Date: 2026-08-02
- Project: Fishing Office / 上班摸鱼
- Production URL: https://fishing.up.railway.app/#/home
- Branch: main
- Repository: https://github.com/gaojian98/fishing-office-mvp.git
- Code hotfix commit: 1db300b092d55a44e7241038fa1326692b38eca6

## Root Cause

The home page rendered normally, but the hotspot layer calculated button rectangles from the global `ResponsiveManager.designSize`, which defaulted to `390 x 844`, while the actual home stage is the frozen `1080 x 1920` design coordinate system.

This caused the transparent hotspot rectangles to be scaled and positioned incorrectly. The visible background image was correct, but user taps did not land on the actual GestureDetector regions.

## Click Blocking Review

- Full-screen transparent layer found: `DialogLayer` returned a full-screen empty `SizedBox.expand()`.
- Blocking widget fixed: `DialogLayer` is now wrapped in `IgnorePointer`.
- Ambient layer status: `AmbientPresentationLayer` already used `IgnorePointer` and did not block taps.
- AbsorbPointer issue: none found on the home page path.
- IgnorePointer issue: no incorrect home-page pointer lock found.
- Runtime permanent loading: none found. Home base buttons remain independent of runtime lock state.
- Coordinate double scaling: found and fixed in `JsonElementLayer`.

## Modified Files

- `fishing_office_flutter/lib/pages/home/widgets/json_element_layer.dart`
- `fishing_office_flutter/lib/pages/home/widgets/home_layout_utils.dart`
- `fishing_office_flutter/lib/pages/home/widgets/dialog_layer.dart`
- `fishing_office_flutter/lib/pages/home/home_page.dart`
- `fishing_office_flutter/assets/config/office_layout.json`
- `fishing_office_flutter/assets/config/office_interaction.json`
- `fishing_office_flutter/test/home_hotspot_test.dart`

## Local Validation

- `flutter clean`: PASS
- `flutter pub get`: PASS
- `flutter analyze`: PASS
- `flutter test`: PASS, 37 tests
- `flutter build web --release`: PASS

Home widget regression test coverage:

- profile: PASS
- help: PASS
- exit: PASS
- store: PASS
- honor: PASS
- inventory: PASS
- fishing: PASS
- task: PASS
- collection: PASS
- transparent presentation layer does not block taps: PASS

## Railway Deployment

- Latest code hotfix commit pushed to `origin/main`: `1db300b092d55a44e7241038fa1326692b38eca6`
- Railway service served updated production artifacts after push.
- Railway deployment ID: not available from local CLI/session. Production verification used live Railway responses and updated asset contents.
- Railway build/deploy result: PASS by production artifact verification.

Observed Railway response headers during validation:

- `/`: HTTP 200
- `/flutter_bootstrap.js`: HTTP 200
- `/main.dart.js`: HTTP 200
- `/manifest.json`: HTTP 200
- `/assets/assets/config/office_layout.json`: HTTP 200
- `/assets/assets/config/office_interaction.json`: HTTP 200

Updated production config confirmed:

- `office_layout.json` contains `fish_book`.
- `office_interaction.json` routes `fish_book` to `FishCollectionDialog`.

## Production Button Validation

Tested with real browser clicks on https://fishing.up.railway.app/#/home.

| Entry | Result | Target |
| --- | --- | --- |
| Avatar / Profile | PASS | `/profile` dialog route |
| Game Guide | PASS | `GameHelpDialog` |
| Exit | PASS | `ExitDialog` |
| Store | PASS | `StoreDialog` |
| Honor | PASS | `HonorDialog` |
| Inventory | PASS | `BagDialog` |
| Start Fishing | PASS | `/fishing` |
| Daily Task | PASS | `TaskDialog` |
| Collection | PASS | `FishCollectionDialog` |

Console status: error count 0.

Network status: no critical 404 observed for entry resources.

## Core Fishing Flow

Production flow tested:

1. Home -> Start Fishing: PASS
2. Waiting state displayed: PASS
3. Fish hooked / can pull line: PASS
4. Pull line opens catch result: PASS
5. Keep fish writes to inventory flow and shows confirmation: PASS
6. Return to home and open inventory afterward: PASS
7. Console errors during flow: 0

## Mobile Viewport Check

Temporary mobile viewport: `390 x 844`.

- Store click: PASS
- Start Fishing click: PASS
- Game Guide click: PASS
- Console errors: 0

## Known Limits

- Railway CLI is not installed/authenticated in this local session, so deployment ID and raw build logs were not directly available.
- Deployment was validated through live production artifacts, HTTP responses, updated JSON contents, and real browser click behavior.

## Recommendation

P0: 0
P1: 0

The home interaction hotfix is validated locally and in production. Recommend product owner perform final manual production acceptance and then reconfirm Gold Master status.
