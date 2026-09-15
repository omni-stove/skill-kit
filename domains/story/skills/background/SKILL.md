---
name: background
description: Build an image-generation prompt for a background / scenery image. Use when the user wants a background-art prompt for a location or scene, giving the scene.
---

Run `.agents/skills/background/refs.sh`

The user supplies the location or scene.

When it is from this project's story, read `README.md` and the `world/` files that describe the location, and for a scene from the story its plot file under `plot/`; otherwise build the prompt from the description alone.

Framing is fixed: scenery only, no people, wide shot. Take time of day, weather, and season from the scene; default to daylight and clear weather.

Follow the loaded rules to question, build, and output the prompt.
