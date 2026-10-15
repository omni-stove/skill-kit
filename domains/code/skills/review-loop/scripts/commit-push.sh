#!/usr/bin/env bash
# Run make lint and make test, commit the given files in one commit and push, merging the
# upstream first when the remote is ahead.
# usage: commit-push.sh <file>...
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

[ "$#" -ge 1 ] || { echo "usage: commit-push.sh <file>...   (the files of this fix batch)" >&2; exit 2; }
make lint || { echo "commit-push: make lint failed — fix it, then rerun" >&2; exit 1; }
make test || { echo "commit-push: make test failed — fix it, then rerun" >&2; exit 1; }

# shellcheck source=/dev/null
source .agents/refs/push-with-merge.sh
git add "$@"
git commit --no-verify -m "fix: address review findings"
push_with_merge
prompt pushed pr="$(gh pr view --json number -q .number 2>/dev/null || echo '<pr>')" >&2
