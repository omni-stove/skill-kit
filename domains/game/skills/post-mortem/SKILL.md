---
name: post-mortem
description: Write or edit a post-mortem for a game milestone — what was planned, what happened, what went right and wrong, and the lessons and actions that follow. Use when the user wants to look back on a release, jam, playtest, or sprint for a game project (e.g. "ポストモーテムを書いて", "振り返りをまとめて", "write a post-mortem for the jam build").
---

Run `.agents/skills/post-mortem/refs.sh`

Determine the milestone, its kebab-case English slug, and the period it covers from what the user gave. Run `.agents/skills/post-mortem/scripts/commits.sh <slug> <start date> [<end date>]`
