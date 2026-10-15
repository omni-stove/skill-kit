---
name: fix-pr
description: Fix a PR's unresolved review threads, CI failures and merge conflicts, then push. Takes a PR number, URL or branch; without one, the current branch's PR. Use when the user asks to address review comments or make a PR's CI pass (e.g. "fix-pr", "レビュー対応して", "PR の CI を通して").
---

Run `.agents/skills/fix-pr/scripts/fetch.sh <pr>`
