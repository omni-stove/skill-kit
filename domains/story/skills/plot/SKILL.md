---
name: plot
description: Create abstract plot concepts and story structure through dialogue. Use when the user wants to develop or check a high-level plot for a project (e.g. "プロットを作って", "develop the plot for <project-id>").
---

Run `.agents/skills/plot/refs.sh`

The user provides a project-id and, optionally, a plot overview. If an existing plot file is specified, check it against the loaded rules instead of creating a new one.

Get each path from `.agents/refs/path <project-id> <what> [name]`; never hand-build one. `<what>`: `readme`, `story_plot` (the dir), `story_plot_file` (takes a kebab-case english title).

Develop high-level plot concepts collaboratively with the author.

Read the `readme` path for world setting and constraints, check existing plots in the `story_plot` directory for context, and read the character and world/setting files relevant to the plot.

Summarize what you found from the files, then develop the plot following the loaded dialogue rules.

Confirm before writing: for new files, ask what to include and get approval before creating; for edits, ask what changes to make and get approval before editing. Always confirm filename and content with the author.

Record the plot (only after author approval):

- Save to the `story_plot_file` path (pass the kebab-case english title)
- Use kebab-case for filenames (no index numbers)
- Files are memos, not necessarily chronological
- `プロットの意図` and `禁止事項` headings are always present; leave their bodies blank unless the author has explicitly stated something to record there
- `参照` uses `@filepath` imports to point at character/place/item/world files

For the full file layout (intent, prohibitions, body, ハイライト, 地の文, 会話, 参照), always apply the loaded rules exactly.
