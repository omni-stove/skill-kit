# Game Design Document (GDD) format

A GDD is a living reference, not a pitch. Write what the game *is* and how it *works* —
concrete, verifiable statements a programmer or designer can build against. Cut anything
that reads as marketing, mood, or wishful scope.

## Rules

- **Facts and decisions, not aspirations.** "Stamina drains 10/s while sprinting" — not
  "the game feels tense and fast-paced". If a number isn't decided yet, mark it `TBD`
  rather than inventing one.
- **Only sections with real content.** The list below is a menu, not a template. Omit
  any section the user has no substance for — do not write empty headers or filler.
- **No self-evident text.** Don't restate the title or genre in prose. Don't explain
  what a "player" or a "level" is.
- **One source of truth.** Cross-link to mechanic / balance / level docs instead of
  duplicating their detail here. The GDD holds the overview; the specifics live in their
  own files under the design root.
- **Testable pillars.** Design pillars must be discriminating — each should let you
  reject a feature. "Every death teaches something" is a pillar; "fun and engaging" is
  not.

## Section menu

```markdown
# [Game Title]

## Overview
One paragraph: what the player does, the core loop, the hook. Genre and platform in one line.

## Design Pillars
2–4 discriminating principles that decide what's in and what's out.

## Core Loop
The moment-to-moment loop (seconds) and the session loop (minutes). Bullet the steps.

## Mechanics
Bullet list of the systems. Link each to its mechanic doc rather than detailing it here.

## Progression
How the player and the game state advance over a playthrough. Unlocks, difficulty curve.

## Controls
Input scheme per platform. Only if decided.

## Content Scope
Counts and kinds: levels, enemies, items, biomes. Concrete numbers or ranges.

## Art & Audio Direction
Concrete direction only (palette, camera, reference), not mood words.

## Technical Constraints
Target hardware, engine, framerate, notable limits.

## Open Questions
Decisions still `TBD`, with what blocks them.
```
