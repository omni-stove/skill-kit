---
name: world
description: Create or edit a world-setting element through dialogue. Use when the user wants to create or edit a world setting, giving an optional overview of the element.
---

Run `.agents/skills/world/refs.sh`

The user provides an optional overview of the world-setting element.

Read `README.md` and list `world/`.

From the overview, determine the element's name, a kebab-case English slug, and category (physical laws, magic system, race, history, society, culture, technology, geography), and how it relates to the existing world settings.

Draft following the loaded rules and format, and write to `world/<slug>.md`.
