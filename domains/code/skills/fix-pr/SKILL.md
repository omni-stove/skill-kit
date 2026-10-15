---
name: fix-pr
description: Fix a PR's unresolved review threads, CI failures and merge conflicts, then push. Takes a PR number, URL or branch; without one, the current branch's PR. Use when the user asks to address review comments or make a PR's CI pass (e.g. "fix-pr", "レビュー対応して", "PR の CI を通して").
---

Run `.agents/skills/fix-pr/scripts/fetch.sh <pr>`

Fix the active review threads, the failing checks, and any conflict, with the smallest change that holds the root cause. Leave a test's assertions and unrelated code as they are. Skip a finding that is wrong or outside the PR's scope and say why in your reply to it.

Run `make lint` and `make test`.

Run `.agents/skills/fix-pr/scripts/commit-push.sh <changed files>`. With no changed files, run it with no arguments; it pushes an empty commit that reruns CI.

Reply to each thread you addressed or skipped with `gh api repos/{owner}/{repo}/pulls/<pr>/comments/<comment_id>/replies -f body="<what you did>"`, using the comment_id from the thread listing. Run `.agents/refs/resolve-review-thread.sh <pr> <thread-id>` for a thread whose fix is pushed.
