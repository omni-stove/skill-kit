---
name: world
description: Create world setting by specifying a project. Use when the user wants to create or edit a world-setting element for a given project id through guided dialogue.
---

The user provides the project-id and optionally an overview of the world setting element to create.

Get each path from `.agents/refs/path <project-id> <what>`; never hand-build one. `<what>`: `readme`, `world` (the dir).

Create and edit world settings through dialogue with the user, storing documents in the `world` directory.

Read the `readme` path to understand the project's world setting and constraints, and list existing files in the `world` directory.

Analyze the overview passed as input and check relationships with existing world settings.

Deep-dive into the settings with `AskUserQuestion`, in selection format whenever possible — group related questions (up to 4) in a single call, each with 2-4 clear options and descriptions:

First call (category & scope): category (physical laws / magic system / race / history / society / culture / technology / geography), scope (entire world / specific region / specific group / specific time period).

Second call (complexity & visibility): complexity (simple / moderate / detailed / intricate), public knowledge (common knowledge / known to experts / secret / lost knowledge), stability (unchanging / slowly evolving / rapidly changing / unstable), documentation (well documented / partially known / oral tradition / undocumented).

Third call (impact & conflict): social impact (none / minor / significant / transformative), conflict potential (peaceful / minor tensions / major conflicts / existential threat), accessibility (universal / requires training / innate only / forbidden), cost/consequence (none / minor cost / significant sacrifice / life-altering).

Then ask category-specific selection questions. For magic/supernatural: source (innate / learned / divine / natural / technological), limitation type (resource-based / physical toll / time-limited / conditional). For society/politics: government type (monarchy / democracy / theocracy / oligarchy / anarchy), social mobility (rigid / limited / moderate / fluid). For technology: era equivalent (ancient / medieval / renaissance / industrial / modern / futuristic), magic-tech integration (none / separate / complementary / merged).

After selections, ask for specific details as free text: specific name of this world element, detailed mechanics or rules, historical background, relationship to other world elements, exceptions and edge cases.

Verify consistency: does it match the settings in project's README.md, does it conflict with existing world settings, is it consistent with genre and tone, and with characters and story.

Present the organized settings, verify consistency with README.md and logical consistency with existing settings, get user confirmation, and adjust as needed.

Create the document in the `world` directory in markdown with consistent format:

- Record unanswered items as TBD
- Avoid overly complex settings; balance uniqueness and plausibility
- **Facts only**: Write in-world fact, not meta commentary on narrative role, plot importance, theme, or reader effect.
- **No self-evident content**: Do not write what is obvious from the name, category, README, or common sense.

Do not write anything outside the format. Structure flexibly according to setting type, but the basic structure is:

```markdown
# [World Setting Element Name]

## Overview
[What this element is, stated as in-world fact.]

## Basic Settings
- **Category**: [category]
- **Scope of Impact**: [scope]

## Detailed Description

### [Section 1]
[Specific description]

### [Section 2]
[Specific description]

### [Add sections as needed]

## Historical Background
[How this setting came to be]
```
