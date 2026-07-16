---
name: tachie
description: Build an image-generation prompt for a character's standing art (立ち絵). Use when the user wants a tachie / standing-art prompt for a character, giving the character and optionally a project id.
---

Run `.agents/skills/tachie/refs.sh`

The user supplies the character and, when it belongs to a project, the project id. Without a project id, build the prompt from the description alone.

Resolve every project path by sourcing the layout — run `sh -c '. .agents/refs/layout.sh; <fn> <project-id>'` and use the path it prints. Never hand-build a path. Functions used here: `readme`, `characters` (the dir).

Find the character's file under the `characters` directory and read it; read the `readme` for era and dress conventions.

Framing is fixed: single character, full body from head to toe, standing, plain solid background. Take pose and expression from the character's settings; default to a neutral standing pose.

Follow the loaded rules to question, build, and output the prompt.
