---
name: item
description: Create item settings by specifying a project, through dialogue with the user, stored under the project's items directory. Use when the user wants to create or edit an item/設定 for a given project.
---

The user provides a project ID and, optionally, a brief overview of the item to create. Use any item overview as the starting point for the basic information.

Resolve every project path by sourcing the layout — run `sh -c '. .agents/refs/layout.sh; <fn> <project-id>'` and use the path it prints. Never hand-build a path. Functions used here: `readme`, `items` (the dir).

Create and edit item settings through dialogue with the user, storing documents in the `items` directory.

Read the `readme` path to understand the project's world setting and constraints, and list existing files in the `items` directory.

Analyze the overview; determine the item name (Japanese, English) and item type (weapon, tool, consumable, knowledge, etc.); check relationships with existing items.

Deep-dive into the settings with `AskUserQuestion`, in selection format whenever possible — group related questions (up to 4) in a single call, each with 2-4 clear options and descriptions:

First call (basic settings): type (weapon / tool / consumable / equipment / knowledge / other), rarity (common / uncommon / rare / unique), origin (manufactured / natural / magical / ancient / unknown), current state (in use / stored / lost / destroyed / prototype).

Second call (physical properties): size (pocket-sized / handheld / carried / large / massive), durability (fragile / normal / durable / indestructible), portability (easy to carry / requires effort / stationary), maintenance (none required / occasional / regular / constant).

Third call (availability & risk): availability (freely available / restricted / forbidden / lost to history), user restriction (anyone / trained users / specific person / bloodline only), risk level (safe / minor risk / dangerous / potentially catastrophic).

After selections, ask for specific details as free text: specific name (Japanese/English), physical appearance and materials, development history and background, operating procedures, advantages and disadvantages, relationships with characters.

Verify consistency with the world setting: does it match project's README.md, is it technically and historically feasible, does it conflict with existing world settings.

Present the organized settings, verify consistency with README.md and existing items, get user confirmation, and adjust as needed.

Create the document in the `items` directory in markdown with consistent format:

- Record unanswered items as TBD
- Consider relationships with characters
- **Facts only**: Write in-world fact, not meta commentary on narrative role, plot importance, theme, or reader effect.
- **No self-evident content**: Do not write what is obvious from the name, type, README, or common sense.

```markdown
# [Item Name - Japanese and English]

## Basic Information
- **Name**:
- **Type**:
- **Purpose**:
- **Administrator/Owner**:
- **Manufacturer**: (if applicable)

## Background
[Development history]

## Detailed Settings

### Appearance/Structure
[Physical appearance, size, shape]

### Materials
[Materials used]

### Specifications
[Technical details, performance]

## Usage

### Operating Procedures
[Usage steps]

### Advantages
[Strengths, benefits]

### Disadvantages
[Weaknesses, limitations, risks]

## Management and Operation
- **Storage Location**:
- **Maintenance**:
- **Person in Charge**:
```
