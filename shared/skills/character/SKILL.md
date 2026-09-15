---
name: character
description: Create or edit a character setting through dialogue. Use when the user wants to create or edit a character setting, giving an optional character overview.
---

Run `.agents/skills/character/refs.sh`

The user provides an optional character overview.

Read `README.md` and list `characters/` (`main`, `supporting`, `antagonist`, `archive`).

From the overview, determine the character name (Japanese, English, nickname) and the category: main, supporting, antagonist, or archive (deceased, retired, or no longer active). Name and category are the required minimum; for an archive character, the departure reason too.

Before presenting a candidate name, `WebSearch` it and pick names clear of recognizable real people and famous existing characters; a common surname overlapping is fine. Attach a one-line note per candidate: what it collides with, or that it is clear. Skip the search only when the user says to; honor a name the user insists on, noting the collision once.

Draft following the loaded rules and format, and write to `characters/<category>/<name>.md`.
