---
name: tachie
description: Build an image-generation prompt for a character's standing art (立ち絵). Use when the user wants a tachie / standing-art prompt for a character, giving the character.
---

Run `.agents/skills/tachie/refs.sh`

The user supplies the character.

When the character is from this project, read their file under `characters/` and `README.md` for era and dress conventions; otherwise build the prompt from the description alone.

Framing is fixed: single character, full body from head to toe, standing, plain solid background. Take pose and expression from the character's settings; default to a neutral standing pose.

Follow the loaded rules to question, build, and output the prompt.
