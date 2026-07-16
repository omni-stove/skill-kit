---
name: character
description: Create character settings by specifying a project. Use when the user wants to create or edit character settings for a story project, providing a project id and an optional character overview.
---

The user specifies the target project id and an optional character overview.

Resolve every project path by sourcing the layout — run `sh -c '. .agents/refs/layout.sh; <fn> <project-id> [name]'` and use the path it prints. Never hand-build a path. Functions used here: `readme`, `characters` (the dir), and `characters_main` / `characters_supporting` / `characters_antagonist` / `characters_archive` (each takes the project id and the character name, e.g. `characters_main co "アリス"`).

Create and edit character settings through dialogue with the user.

Read the `readme` path to understand the project's world setting and constraints, and list existing files under the `characters` directory (its `main`, `supporting`, `antagonist`, `archive` subdirectories).

Analyze the overview provided by the user; determine the character name (Japanese name, English name, nickname, etc.) and the category (main / supporting / antagonist / archive).

Before presenting any candidate name — full name, English name, or distinctive nickname — `WebSearch` it and pick names that stay clear of recognizable real people and famous existing characters. Common surnames (佐藤, 田中) overlapping is fine; a recognizable full name or distinctive given name that evokes a specific figure is not — replace it. Attach a one-line note per candidate: what it collides with, or that it's clear. Skip the search only when the user says to; honor a name the user insists on, noting the collision once.

Clarify only what's missing. Do NOT ask preset attribute checklists — only ask when information that is structurally required and not derivable from the overview is missing.

- Required minimum: name, category.
- If the overview already implies these, do not ask. Confirm only if genuinely ambiguous.
- Combine any unavoidable questions into a single `AskUserQuestion` call. Maximum one round.
- Do NOT ask about build, clothing style, personality type, speech style, combat ability, background type, goal type, etc. unless the user explicitly invited such proposals.
- For archive characters, ask the departure reason only if it isn't in the overview.

Present the organized settings, verify consistency with the README.md world setting and with existing characters, get user confirmation, and adjust as needed.

Create the document in markdown with consistent format, at the path returned by the function for the chosen category:

- Main characters: `characters_main`
- Supporting characters: `characters_supporting`
- Antagonist characters: `characters_antagonist`
- Archived characters: `characters_archive` (deceased, retired, or no longer active in the story)

- If the user says "任せる", or a detail can be derived neither from the overview nor the README, omit that section entirely.
- Only include sections that have substantive content drawn from the user's input or the project README. Skip empty sections.
- **Facts only**: Write in-world fact, not meta commentary on narrative role, plot importance, theme, or reader effect. State what happened or what is true; do not interpret, editorialize, or spell out irony. Prohibited: authorial framing words; theme or irony spelled out for the reader; defensive negations addressed to an imagined reader; narrative-role or reader-effect commentary.
- **No self-evident content**: Do not write what is obvious from the name, category, README, or common sense.

The following is a **menu of possible sections**, not a required template. Include only sections for which the user provided (or the overview clearly implies) concrete content. Omit the rest entirely — do not write empty headers.

```markdown
# [Character Name]

## Basic Information
- Name
- (Include only fields that have values.)

## Archive Information
(Only for archived characters, only fields with content.)

## Appearance
## Personality
## Speech Patterns
## Background
## Abilities/Skills
## Weapons/Equipment
## Motivations/Goals
```
