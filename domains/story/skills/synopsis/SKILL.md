---
name: synopsis
description: Generate a synopsis (梗概) for a story project. Use when the user asks to create or revise a 梗概/synopsis for a given project id.
---

The user provides the project-id.

Get each path from `.agents/refs/path <project-id> <what>`; never hand-build one. `<what>`: `readme`, `characters`, `story_synopsis`.

The story itself is the one already read in this conversation. Read the `readme` path and key character files from the `characters` directory. If a file exists at the `story_synopsis` path, read it and revise it instead of drafting from scratch.

Align on direction with a single `AskUserQuestion` call: length (400字以内 / 800字程度 / 1200字以上 / お任せ), mandatory elements, elements to omit or downplay, target contest or audience. If contest rules are provided in this conversation, draft to their evaluation criteria.

Draft the 梗概:

- キャッチコピー or ジャンル情報 → 導入 → 展開 → 結末 の順に構成する
- State the protagonist, their goal, and the central conflict early
- Connect events through character decisions
- Keep one through-line; include the key turning points and cut episodes that don't serve it
- Let the theme come through the events, not as a stated moral

Present the draft to the author and revise on feedback.

Run `.agents/skills/synopsis/scripts/save.sh <story_synopsis path>` with the 梗概本文 only on stdin.
