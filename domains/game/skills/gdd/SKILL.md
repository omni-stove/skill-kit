---
name: gdd
description: Create or edit the game design document (GDD) — the living overview of what the game is and how it works. Use when the user wants to write, update, or review the GDD / design overview for a game project (e.g. "GDDを書いて", "game design documentを作って", "設計ドキュメントをまとめて").
---

# Game design document

Create and edit the GDD through dialogue with the user — the big-picture overview, with
per-system detail living in its own mechanic / balance / level docs.

Run `.agents/skills/gdd/scripts/context.sh` for the GDD path, the design root, and the
format contract.

If the GDD file already exists, read it and edit in place — refine, don't restart. List
the design root to see which mechanic / balance / level docs exist, and link them rather
than restating them.

Understand the game from the user's overview. Ask only where a real gap blocks the
document — not down a preset genre/platform checklist — and batch those questions into a
single `AskUserQuestion` round.

Draft following the format. Where the user says "任せる" and nothing can be derived, omit
that section rather than filling it with mood words.

Present it, verify consistency with any existing design docs, confirm, adjust, then write
to the GDD path.
