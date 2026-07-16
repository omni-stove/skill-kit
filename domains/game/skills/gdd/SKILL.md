---
name: gdd
description: Create or edit the game design document (GDD) — the living overview of what the game is and how it works. Use when the user wants to write, update, or review the GDD / design overview for a game project (e.g. "GDDを書いて", "game design documentを作って", "設計ドキュメントをまとめて").
---

# Game design document

Create and edit the GDD through dialogue with the user — the big-picture overview, with
per-system detail living in its own mechanic / balance / level docs.

Run `.agents/skills/gdd/scripts/context.sh` for the GDD path, the design root, and the
format contract. Follow that format: facts and decisions over aspirations, sections only
where there's real content, cross-link to the other design docs instead of duplicating
their detail.

If the GDD file already exists, read it and edit in place — refine, don't restart. List
the design root to see which mechanic / balance / level docs exist, and link them rather
than restating them.

Understand the game from the user's overview. Clarify only what's structurally required
and not derivable — batch unavoidable questions into a single `AskUserQuestion` round.
Ask only where a real gap blocks the document, not down a preset genre/platform checklist.

Draft following the format. Design pillars must each be able to reject a feature.
Undecided numbers are `TBD`, not invented. Omit empty headers — the format is a menu, not
a template; where the user says "任せる" and nothing can be derived, omit that section
rather than filling it with mood words. When a section wants to go deep, keep the GDD to
the overview and link out to the per-system doc.

Present it, verify consistency with any existing design docs, confirm, adjust, then write
to the GDD path (creating parent dirs as needed).
