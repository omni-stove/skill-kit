---
name: post-mortem
description: Write or edit a post-mortem for a game milestone — what was planned, what happened, what went right and wrong, and the lessons and actions that follow. Use when the user wants to look back on a release, jam, playtest, or sprint for a game project (e.g. "ポストモーテムを書いて", "振り返りをまとめて", "write a post-mortem for the jam build").
---

Run `.agents/skills/post-mortem/refs.sh`

The user provides the milestone and what happened, or the change they want.

Determine the milestone, a kebab-case English slug, and the period it covers. Run `.agents/skills/post-mortem/scripts/commits.sh <since> [<until>]` for the period's commits.

List `docs/design/post-mortems/`; read the earlier post-mortems and `docs/design/gdd.md`.

Separate what happened from why: push each wrong item to its root cause, and each lesson to a rule the next milestone can follow. Flag a lesson an earlier post-mortem already drew.

Draft following the loaded rules and format, and write to `docs/design/post-mortems/<slug>.md`.
