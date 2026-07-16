---
name: synopsis
description: Generate a synopsis (梗概) for a story project. Use when the user asks to create or revise a 梗概/synopsis for a given project id.
---

The user provides the project-id.

The synopsis summarizes the entire story in a concise narrative for submission purposes.

Get each path from `.agents/refs/path <project-id> <what>`; never hand-build one. `<what>`: `readme`, `story_outline`, `characters`, `story_plot`, `story_synopsis`.

Read the `readme` path, all files in the `story_outline` directory, key character files from the `characters` directory, and any plot files in the `story_plot` directory for detailed story beats.

If a file already exists at the `story_synopsis` path, read it and use it as a base for revision.

Identify the main narrative thread from beginning to end, the key turning points, revelations, and the climax; understand character motivations and how they drive the plot; identify the thematic core.

Align on direction with a single `AskUserQuestion` call: length (short 400字以内 / standard 800字程度 / long 1200字以上 / let you decide), mandatory elements to include (specific themes, genre keywords), elements to omit or downplay, target audience or contest requirements.

Draft:

- 梗概は結末まで含めること（ネタバレ前提）
- Structure: キャッチコピー or ジャンル情報 → 導入 → 展開 → 結末
- Focus on causality: events should connect through character decisions
- Avoid listing episodes; instead show the story's through-line

Quality checklist:

- Main character and their goal are clear
- Central conflict is identified
- Key turning points are included
- Causality chain is maintained (A because B, not just A then B)
- Ending/resolution is included
- Thematic essence is conveyed
- Reads as a coherent narrative, not a bullet list

Present the draft to the author, revise based on feedback, and ensure it reads as a compelling summary, not a dry outline.

Save to the `story_synopsis` path — the file contains the 梗概本文 only.
