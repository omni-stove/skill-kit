---
name: staging
description: Check scene-level description quality in a single story file. Use when the user asks to staging-check a file (e.g. "stagingチェックして").
---

Run `.agents/skills/staging/refs.sh`

Read only the file the user gave and detect scene-level description quality issues, applying the loaded rules exactly.

Run `.agents/skills/staging/scripts/save.sh <the same path>` with the report on stdin.
