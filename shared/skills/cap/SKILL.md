---
name: cap
description: Commit all current changes and push to the current branch.
---

Write a concise commit message from the diff, then commit all changes and push to the current branch.

Run `git status` and `git diff` to review the changes, and `git log` for recent commit message style.

Then, from the repo root:

- Stage all changes (`git add -A`).
- If there are no changes, do nothing and stop.
- Commit with a concise message generated from the diff (follow existing commit message style).
- Run `.agents/skills/cap/scripts/push.sh`. Never force-push or create a new branch; push to the current branch as-is, including `main`.

Perform only history-preserving operations. Display the result and confirm.

Requires a configured git remote and authentication.
