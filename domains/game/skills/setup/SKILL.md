---
name: setup
description: Adapt the kit to this repo's game engine. Use when setting up skill-kit in a new game repo or one on a non-default engine.
---

Run `.agents/skills/setup/refs.sh`

Follow the loaded rules to detect this repo's engine, generate the override, verify the resolved values, and end with `git status` confirming the override file appears in it as a real file (not a symlink, not ignored) and nothing else changed.
