#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---check}"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

case "$MODE" in
  --check|--show-plan|--verify-files) ;;
  --execute)
    echo "ERROR: --execute is intentionally disabled for this helper. Use AUTHORIZED_COMMANDS.md manually after product owner authorization." >&2
    exit 2
    ;;
  *)
    echo "Usage: $0 [--check|--show-plan|--verify-files]" >&2
    exit 2
    ;;
esac

branch="$(git branch --show-current)"
if [[ "$branch" != "feature/v1.1-office-life-schedule" && "$branch" != "rc/v1.2.0-rc.1" ]]; then
  echo "ERROR: unexpected branch: $branch" >&2
  exit 1
fi

if git status --porcelain=v1 -uall | grep -E '(^.. build/|^.. fishing_office_flutter/build/|\.dart_tool/|\.DS_Store$|\.log$|\.tmp$|\.bak$|\.railway/)'; then
  echo "ERROR: forbidden file appears in git status" >&2
  exit 1
fi

if git status --porcelain=v1 -uall | grep -E '^.. 106_Releases/v1\.0\.0/'; then
  echo "ERROR: protected v1.0.0 release files are modified" >&2
  exit 1
fi

if [[ "$MODE" == "--show-plan" ]]; then
  sed -n '1,260p' 00_Project/v1.2.0/Release_Package/COMMIT_PLAN.md
fi

if [[ "$MODE" == "--verify-files" ]]; then
  for f in     CHANGELOG.md     README.md     00_Project/v1.2.0/v1.2.0_RC1_Release_Notes.md     00_Project/v1.2.0/Release_Package/RELEASE_MANIFEST.md     00_Project/v1.2.0/Release_Package/FILE_CHANGE_MANIFEST.md     00_Project/v1.2.0/Release_Package/COMMIT_PLAN.md     00_Project/v1.2.0/Release_Package/AUTHORIZED_COMMANDS.md; do
    test -f "$f" || { echo "ERROR: missing $f" >&2; exit 1; }
  done
fi

echo "prepare_v1_2_rc_commits: $MODE PASS"
