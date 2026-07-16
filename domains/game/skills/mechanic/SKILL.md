---
name: mechanic
description: Design or document a single game mechanic/system precisely enough to implement and balance — input, behaviour, states, parameters, edge cases. Use when the user wants to spec out a mechanic, ability, or system for a game project (e.g. "○○のメカニクスを設計して", "ダッシュの仕様をまとめて", "spec this ability").
---

# Mechanic spec

Design and document one mechanic through dialogue with the user — tight enough that a
programmer can implement it and a designer can balance it.

Determine the mechanic name and a lowercase-dashed slug. Run
`.agents/skills/mechanic/scripts/context.sh <slug>` for the mechanics dir, the target file
path, the GDD path, and the format contract. List the mechanics dir; if this mechanic
exists, edit it in place rather than duplicating. Read the GDD if present, so the mechanic
stays consistent with the game's pillars and loop.

Draw out the spec through dialogue. The high-value parts are the state machine and the
edge cases — push on what happens when it's interrupted, re-triggered while active, or
used with no resource. Clarify only genuine gaps; batch questions into one
`AskUserQuestion` round.

Draft following the format: every rule implementable, states and transitions enumerated,
edge cases as the spec, undecided numbers `TBD` with what decides them. Put tunable
numbers in the parameters table; a value that belongs to a balance pass is marked and left
to the balance doc, not fixed here. Omit empty headers. Describe what the system does, not
how fun it is.

Present, check consistency with the GDD and interacting mechanics, confirm, adjust, then
write to the target file. If this mechanic isn't yet in the GDD's Mechanics section, offer
to add a link there so the overview stays in sync.
