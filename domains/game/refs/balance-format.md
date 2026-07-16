# Balance doc format

A balance doc is a table of decisions with their rationale — what value, and why that
value. Behaviour lives in the mechanic doc; this doc holds the numbers, the curves that
relate them, and the reasoning that justifies each.

## Rules

- **Every number carries a reason.** A value with no rationale is a guess — mark it `TBD`
  and note what would decide it rather than committing a number you can't justify.
- **State the curve, not just the points.** Where values relate — a cost ramp, an
  XP-to-level curve, damage falloff — give the formula or curve shape, not isolated
  numbers.
- **Consistency over completeness.** Better to leave a value `TBD` than to ship a table
  that contradicts the mechanic doc or the GDD.
- **Only sections with content.** Menu, not template. Omit what doesn't apply.

## Section menu

```markdown
# [System] Balance

## Goal
What this balance should achieve (e.g. "a run lasts 20–30 min", "no single weapon dominates").

## Values
| Parameter | Value | Unit | Rationale |
|---|---|---|---|
| … | … | … | why this, what breaks otherwise |

## Curves
Formulas or curve shapes for related values (cost ramps, XP-to-level, damage falloff).

## Tuning Notes
Known tensions, what to watch in play-test, values most likely to need revisiting.

## Open Questions
Undecided values and what data would settle them.
```
