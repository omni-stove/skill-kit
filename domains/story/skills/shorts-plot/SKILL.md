---
name: shorts-plot
description: Develop the plot of a short story under src/shorts/. Use when the user wants a short story's plot made.
---

Run `.agents/skills/shorts-plot/refs.sh`

対象短編の short-id を受け取る。

Read `src/shorts/<short-id>/README.md` for context if present, then develop the plot following the loaded dialogue rules.

Confirm the overwrite with the author when `src/shorts/<short-id>/plot.md` exists, then write the file by the loaded rules with this one command, leaving out the options that stay empty: `.agents/refs/plot-skeleton.sh src/shorts/<short-id>/plot.md --body <text> --intent <text> --length <text> --prohibited <text> --highlights <text> --references <text>`
