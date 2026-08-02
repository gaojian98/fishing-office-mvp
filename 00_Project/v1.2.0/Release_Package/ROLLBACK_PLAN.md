# Rollback Plan

## Scenario 1: Commit After Test Failure

- Signal: local analyze/test/build fails after one grouped commit.
- Stop: do not push.
- Check: inspect failing commit diff and test output.
- Rollback: use a normal `git revert <commit>` if already committed locally, or unstage with `git restore --staged <path>` before commit.
- Data risk: none if not deployed.
- Verify: rerun targeted test, then full validation.

## Scenario 2: Push After Staging Build Failure

- Signal: Railway staging build fails.
- Stop: do not tag or promote.
- Check: Dockerfile, root directory, Flutter build logs.
- Rollback: push a normal revert commit to RC branch.
- Data risk: none for production.
- Verify: new staging build PASS.

## Scenario 3: Staging Page White Screen

- Signal: `/` loads but app is blank or Console has red errors.
- Stop: do not promote.
- Check: `main.dart.js`, asset paths, Console stack, Network 404.
- Rollback: revert the failing RC commit or return staging branch to previous good commit by normal commit.
- Data risk: staging local storage only.
- Verify: hard refresh and resource checks.

## Scenario 4: Critical JSON 404

- Signal: `resident_dialogue.json`, `office_dialog.json`, or other registered config returns 404.
- Stop: do not promote.
- Check: `pubspec.yaml`, file case, Docker build output.
- Rollback: revert asset registration/content path change.
- Data risk: runtime init may fallback in staging only.
- Verify: Network resources return 200 JSON.

## Scenario 5: Home Buttons No Response

- Signal: home renders but entries do not open.
- Stop: do not promote.
- Check: overlay layers, `IgnorePointer`, hotspot config, Console.
- Rollback: revert relevant UI/pointer commit.
- Data risk: none.
- Verify: 9-entry browser click checklist.

## Scenario 6: Old Save Load Failure

- Signal: old browser data causes startup failure or missing state.
- Stop: do not promote.
- Check: `WorldSaveData.fromJson`, migration defaults, Local Storage.
- Rollback: revert save schema commit or add a forward-compatible fallback in a new fix commit.
- Data risk: staging saves are not production saves.
- Verify: old save and damaged save tests.

## Scenario 7: Duplicate Reward Or Transaction Inconsistency

- Signal: repeated reward, negative asset, or duplicate transaction.
- Stop: do not promote.
- Check: processed action IDs, task rewards, interaction history, transaction guards.
- Rollback: revert offending settlement commit.
- Data risk: staging test data only.
- Verify: duplicate settlement tests and manual flow.

## Scenario 8: Railway Docker Build Failure

- Signal: Docker build fails before deploy.
- Stop: do not promote.
- Check: root directory, Dockerfile path, Flutter SDK image, pub get/build logs.
- Rollback: fix staging config or revert Docker/server commit.
- Data risk: none.
- Verify: staging build PASS and service starts.

## Data Rollback Boundary

- v1.0/v1.1 save fields are loaded with defaults when v1.2 fields are missing.
- New v1.2 fields can be ignored by older code only if older code never reads that save blob.
- Do not use staging Local Storage as production data.
- Before manual staging tests, export browser Local Storage if it must be preserved.
- Do not promise automatic downgrade of v1.2-enriched saves into v1.0 production.
- Prevent repeat migration by checking processed IDs and save version fields.
