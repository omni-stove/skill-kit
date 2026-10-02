---
name: mechanic
description: Design or document a single game mechanic/system precisely enough to implement and balance — input, behaviour, states, parameters, edge cases. Use when the user wants to spec out a mechanic, ability, or system for a game project (e.g. "○○のメカニクスを設計して", "ダッシュの仕様をまとめて", "spec this ability").
---

Run `.agents/skills/mechanic/refs.sh`

The user provides the mechanic and, optionally, what they know about it.

Determine the mechanic name and a kebab-case English slug.

List `docs/design/mechanics/` and read `docs/design/gdd.md`.

Draw out the states, the transitions, and the edge cases.

Draft following the loaded rules and format, and write to `docs/design/mechanics/<slug>.md`. If the GDD's Mechanics section lacks this mechanic, offer to add a link there.
