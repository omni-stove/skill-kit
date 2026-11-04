---
name: character
description: Create or edit a character setting through dialogue. Use when the user wants to create or edit a character setting, giving an optional character overview.
---

Run `.agents/skills/character/refs.sh`

The user provides an optional character overview.

Read `README.md` and list `characters/` (`main`, `supporting`, `antagonist`, `archive`).

From the overview, determine the character name (Japanese, English, nickname), a kebab-case English slug, and the category: main, supporting, antagonist, or archive (deceased, retired, or no longer active). Name and category are the required minimum; for an archive character, the departure reason too.

Run `.agents/skills/character/scripts/names.sh <name>...` with every form and part of each candidate name, and of a name the user gave for a new character.

`WebSearch` each candidate. Pick candidates clear of the collisions above and of real people and characters a reader would recognize; a shared surname counts only when it is rare. Attach a one-line note per candidate: what it collides with, or that it is clear. Skip the searches only when the user says to; honor a name the user gave or insists on, noting the collision once.

Draft following the loaded rules and format, and write to `characters/<category>/<slug>.md`.
