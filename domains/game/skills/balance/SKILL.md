---
name: balance
description: Design or document the balance of a game system — the tunable numbers, the curves, and the reasoning behind them (economy, progression, damage, difficulty). Use when the user wants to define, tune, or review balance values for a game project (e.g. "バランスを調整して", "経済のパラメータをまとめて", "tune the difficulty curve").
---

Run `.agents/skills/balance/refs.sh`

The user provides the system to balance and, optionally, the values they have in mind.

Determine the system and a lowercase-dashed slug.

List `docs/design/balance/`; read the docs under `docs/design/mechanics/` this balance governs, and `docs/design/gdd.md`.

Work out the values with the user. Flag where costs and rewards don't balance over a session, where difficulty dips without intent, and where a dominant or dead option falls out of the numbers.

Draft following the loaded rules and format, and write to `docs/design/balance/<slug>.md`.
