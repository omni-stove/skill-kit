---
name: balance
description: Design or document the balance of a game system — the tunable numbers, the curves, and the reasoning behind them (economy, progression, damage, difficulty). Use when the user wants to define, tune, or review balance values for a game project (e.g. "バランスを調整して", "経済のパラメータをまとめて", "tune the difficulty curve").
---

# System balance

Design and document the balance of one system through dialogue with the user — the
numbers, the curves connecting them, and the reasoning that justifies each. Behaviour
lives in the mechanic doc; this doc answers what value, and why that value.

Determine which system is being balanced and a lowercase-dashed slug. Run
`.agents/skills/balance/scripts/context.sh <slug>` for the balance dir, the target file
path, the mechanics dir, the GDD path, and the format contract. List the balance dir; edit
in place if the file exists. Read the mechanic(s) this balance governs and the GDD if
present, so the values respect the system's parameters and the game's pillars.

Work out the values with the user. For each tunable, capture the value (or a range /
`TBD`), its unit, and a one-line reason it's set there — what breaks if it's higher or
lower. Where values relate — a cost curve, a damage-vs-level ramp — state the formula or
curve shape, not just isolated points.

Cross-check for consistency: costs balance against rewards over a session, difficulty
ramps monotonically unless intended otherwise, no dominant or dead option falls out of the
numbers. Better to leave a value `TBD` than to ship a table that contradicts the mechanic
doc or the GDD; flag anything that doesn't hold.

Draft following the format, present, confirm, then write to the target file.
