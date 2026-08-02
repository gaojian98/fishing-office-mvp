# Remote Branch Strategy

Task: v1.2.0 Module 11
Generated at: 2026-08-03 00:56:27 +07

## Current Branch Situation

- Local branch: feature/v1.1-office-life-schedule
- Local HEAD: a9f76e250f5152f548e265a326310d7d29bfa282
- origin/main: 1bbd8841272dea48a6c87bebc961f3b2019eabc6
- Ahead / behind: 6 / 0
- Remote branch `feature/v1.1-office-life-schedule`: not present in `git ls-remote`
- Remote branch `rc/v1.2.0-rc.1`: not present in `git ls-remote`

## Strategy Options

### Scheme A: Push Current Feature Branch

Command draft:

```bash
git push -u origin feature/v1.1-office-life-schedule
```

Assessment:
- Good for remote backup.
- Less clear as a v1.2.0 RC handoff because the branch name still says v1.1.
- Not preferred for staging unless Railway is intentionally configured to watch this branch.

### Scheme B: Create And Push RC Branch

Command draft:

```bash
git switch -c rc/v1.2.0-rc.1
git push -u origin rc/v1.2.0-rc.1
```

Assessment:
- Clear RC boundary.
- Good future target for Railway Staging.
- Should be done only after uncommitted release evidence is resolved.

### Scheme C: Follow-Up Docs Commit, Then RC Branch

Recommended.

Reason:
- `AUTHORIZATION_CHECKLIST.md`, `COMMIT_EXECUTION_REPORT.md`, and Module 11 gate reports are release evidence.
- Keeping them uncommitted during final Push would make remote RC history incomplete.
- A small authorized docs-only commit should be created first, then `rc/v1.2.0-rc.1` should be created and pushed.

## Recommended Sequence

Requires explicit product owner authorization before each publishing step:

1. Authorize one docs-only follow-up commit for the uncommitted release evidence files.
2. Re-run `git diff --check`, `flutter analyze`, `flutter test`, and `flutter build web --release`.
3. Create local RC branch `rc/v1.2.0-rc.1`.
4. Push only the RC branch to origin.
5. Do not create or push tags.
6. Do not merge main.
7. Do not deploy Railway production.
8. Configure Railway Staging manually only after separate authorization.

## Rollback And Failure Handling

- Push fails: stop, preserve logs, do not retry with force.
- Remote branch exists: stop and compare remote state before deciding.
- Remote branch is ahead: stop; do not merge, pull, or rebase without authorization.
- CI fails: stop and create a fix commit only after authorization.
- Railway unexpectedly triggers: stop, preserve deployment evidence, and do not promote.
- Sensitive information discovered: stop immediately and escalate; do not force push or rewrite history without explicit incident authorization.

## Recommendation

Recommended remote branch strategy: Scheme C.

Module 12 product owner authorization approves Scheme C execution after the docs-only follow-up commit and validation pass.

No branch creation or push had been executed at the time this file entered the docs-only follow-up commit.
