---
name: review-loop
description: Drive a PR through the automated review and fix cycle until the latest head has an LGTM verdict, passing checks and no unresolved thread — waiting while automation runs, auditing what it pushed, fixing what remains, and repeating. Takes a PR number or URL. Use when the user wants a PR watched until review clears (e.g. "review-loop", "LGTM まで回して", "レビューが通るまで見てて").
---

Run `.agents/skills/review-loop/scripts/watch.sh <pr>`

Read the issue and design documents the PR cites before judging any change.

Audit the batch that settled. Read every automated commit since the last commit of yours as an exact diff, every new review thread, and every failed check. Sort each finding and each automated change into: a valid defect fix; overengineering or a needless abstraction; a departure from the agreed design or a public contract; wrong against the code, the tests or an authoritative source; or not actionable here. An automated change that silently rewrote a canonical document, weakened authorization, altered an API contract, added an implicit limit, or hand-edited a generated file is reverted.

When the watch output shows `Verdict: LGTM`, no failing check and no active thread for the current head, run the completion audit below. Otherwise revert the drift, fix the valid findings in one focused batch, run `make lint` and `make test`, commit and push once. Reply to every thread you addressed or rejected with the pushed commit or the evidence, with `gh api repos/{owner}/{repo}/pulls/<pr>/comments/<comment_id>/replies -f body=...`; a rejection names the design document, issue or decision it rests on. Run `.agents/refs/resolve-review-thread.sh <pr> <thread-id>` for each thread whose reply is posted. Keep an accepted design against a reviewer who proposes another one.

Run `.agents/skills/review-loop/scripts/watch.sh <pr>` again after a push. When no push was needed and nothing remains that a reply did not settle, stop and hand the open findings to the user with your reasons.

Completion audit, all against the same head: the verdict is LGTM, every check passed, the active thread count is zero, every addressed or rejected finding has a reply and is resolved, nothing is still queued, the local branch matches the remote head, and the worktree is clean. Report the head SHA, the batches audited, what was accepted and reverted, and the PR state.
