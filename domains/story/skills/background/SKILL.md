---
name: background
description: Build an image-generation prompt for a background / scenery image. Use when the user wants a background-art prompt for a location or scene, giving the scene and optionally a project id.
---

Run `.agents/skills/background/refs.sh`

The user supplies the location or scene and, when it belongs to a project, the project id. Without a project id, build the prompt from the description alone.

Resolve every project path by sourcing the layout — run `sh -c '. .agents/refs/layout.sh; <fn> <project-id>'` and use the path it prints. Never hand-build a path. Functions used here: `readme`, `world`, `story_plot`.

Read the `readme` and the `world` files that describe the location; for a scene from the story, read its plot file.

Framing is fixed: scenery only, no people, wide shot. Take time of day, weather, and season from the scene; default to daylight and clear weather.

Follow the loaded rules to question, build, and output the prompt.
