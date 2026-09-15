---
name: synopsis
description: Generate a synopsis (梗概) for the story. Use when the user asks to create or revise a 梗概/synopsis.
---

The story itself is the one already read in this conversation. Read `README.md` and key character files under `characters/`. If `story/synopsis.txt` exists, read it and revise it instead of drafting from scratch.

Align on direction with a single `AskUserQuestion` call: length (400字以内 / 800字程度 / 1200字以上 / お任せ), mandatory elements, elements to omit or downplay, target contest or audience. If contest rules are provided in this conversation, draft to their evaluation criteria.

Draft the 梗概:

- キャッチコピー or ジャンル情報 → 導入 → 展開 → 結末 の順に構成する
- State the protagonist, their goal, and the central conflict early
- Connect events through character decisions
- Keep one through-line; include the key turning points and cut episodes that don't serve it
- Let the theme come through the events, not as a stated moral

Present the draft to the author and revise on feedback.

Run `.agents/skills/synopsis/scripts/save.sh` with the 梗概本文 only on stdin.
