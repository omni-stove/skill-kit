---
name: review-loop
description: Drive a PR through the automated review and fix cycle until the latest head has an LGTM verdict, passing checks and no unresolved thread. Takes a PR number or URL. Use when the user wants a PR watched until review clears (e.g. "review-loop", "LGTM まで回して", "レビューが通るまで見てて").
---

Run `.agents/skills/review-loop/scripts/watch.sh <pr>`
