---
name: plot
description: Create abstract plot concepts and story structure through dialogue. Use when the user wants to develop or check a high-level plot (e.g. "プロットを作って", "develop the plot").
---

Run `.agents/skills/plot/refs.sh`

The user provides an optional plot overview. If an existing plot file is specified, check it against the loaded rules instead of creating a new one.

Develop high-level plot concepts collaboratively with the author.

Run `.agents/skills/plot/scripts/path.sh`. Read `README.md` for world setting and constraints, the printed plots for context, and the character and world/setting files relevant to the plot.

Summarize what you found from the files, then develop the plot following the loaded dialogue rules.

Run `.agents/skills/plot/scripts/path.sh <kebab-case English title>`

Confirm the path and content with the author, then write the file. Files are memos, not necessarily chronological.
