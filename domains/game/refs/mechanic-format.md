# Mechanic spec format

A mechanic spec holds what the player does, what the game does in response, and every rule that governs it.

```markdown
# [Mechanic Name]

## Summary
One or two sentences: what it is.

## Player Input
The exact input per platform: hold vs tap, charge, combo.

## Behaviour
What happens, step by step.

## States & Transitions
Each state, and each transition with its trigger and duration.

## Parameters
Table of the tunable values: name, unit, notes, and the value, `TBD`, or a reference to the balance doc.

## Interactions
How it combines with other mechanics: cancels, stacks, is blocked by, enables.

## Edge Cases
Interrupted mid-action, triggered while already active, used with zero resource, and the like, each with its resolved behaviour.

## Feedback
The audiovisual and haptic cues that tell the player it happened.

## Open Questions
Undecided rules or values and what blocks each.
```
