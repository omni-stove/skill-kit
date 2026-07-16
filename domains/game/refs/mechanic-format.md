# Mechanic spec format

A mechanic spec pins down one system precisely enough to implement and to balance. It
answers: what the player does, what the game does in response, and every rule and number
that governs it. It is not a feature wish — it is a contract between design and code.

## Rules

- **Implementable.** Every rule must be something a programmer can turn into code
  without guessing. If a value is undecided, write `TBD` and note what decides it — never
  invent a placeholder number that reads as final.
- **State the states.** Enumerate the mechanic's states and the transitions between them
  (idle → charging → active → cooldown). Ambiguous state machines are the top source of
  bugs.
- **Edge cases are the spec.** What happens at the boundaries — interrupted mid-action,
  triggered while already active, used with zero resource — is the part worth writing.
- **Only sections with content.** Menu, not template. Omit what doesn't apply.
- **Cross-link, don't duplicate.** Numbers that belong to a balance pass live in the
  balance doc; reference them, don't copy them.

## Section menu

```markdown
# [Mechanic Name]

## Summary
One or two sentences: what it is and why it exists in the game.

## Player Input
The exact input(s) that trigger it, per platform. Hold vs tap, charge, combo.

## Behaviour
What happens, step by step. The rules the system follows.

## States & Transitions
The states and what moves between them, including triggers and durations.

## Parameters
Table of tunable values (name, value or TBD, unit, notes). These are what balance tunes.

## Interactions
How it combines with other mechanics — cancels, stacks, is blocked by, enables.

## Edge Cases
Boundary and conflict cases and their resolved behaviour.

## Feedback
The audiovisual/haptic feedback that tells the player it happened. Concrete cues only.

## Open Questions
Undecided rules or values, and what blocks them.
```
