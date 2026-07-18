---
name: balance
description: Design or document the balance of a game system — the tunable numbers, the curves, and the reasoning behind them (economy, progression, damage, difficulty). Use when the user wants to define, tune, or review balance values for a game project (e.g. "バランスを調整して", "経済のパラメータをまとめて", "tune the difficulty curve").
---

# System balance

Design and document the balance of one system through dialogue with the user — the
numbers, the curves connecting them, and the reasoning that justifies each.

Determine which system is being balanced and a lowercase-dashed slug. Run
`.agents/skills/balance/scripts/context.sh <slug>` for the balance dir, the target file
path, the mechanics dir, the GDD path, and the format contract. List the balance dir; edit
in place if the file exists. Read the mechanic(s) this balance governs and the GDD if
present, so the values respect the system's parameters and the game's pillars.

Work out the values with the user. Cross-check for consistency: costs balance against
rewards over a session, difficulty ramps monotonically unless intended otherwise, no
dominant or dead option falls out of the numbers; flag anything that doesn't hold.

Draft following the format, present, confirm, then write to the target file.
