---
name: staging
description: Check scene-level description quality (white room, disembodied speech, sensory imbalance, POV, etc.). Use when the user asks to staging-check a single story file for description-quality issues at the scene level.
---

Run `.agents/skills/staging/refs.sh`

The user provides the path to a target file.

Read the target file and detect scene-level description quality issues, applying the loaded rules exactly. Scope: scenes within the single file. No cross-file reference.
