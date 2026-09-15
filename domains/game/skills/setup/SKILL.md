---
name: setup
description: Adapt the kit to this repo by generating this repo's real .agents/refs/engine.sh whose functions return this engine's actual facts. Use when setting up skill-kit in a game repo — a new repo or a non-default engine (e.g. "setup", "このリポジトリ用に設定して", "Godot用に合わせて").
---

Run `.agents/skills/setup/refs.sh`

Follow the loaded rules to detect this repo's engine, generate the override, verify the resolved values, and end with `git status` confirming the override file shows as a real, tracked file (not ignored) and nothing else changed.
