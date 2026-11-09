---
name: shorts-plot
description: src/shorts/ 配下の短編のプロットを作成する。Use when the user wants to develop a plot for a short story under src/shorts/ and gives a short id.
---

Run `.agents/skills/shorts-plot/refs.sh`

対象短編の short-id を受け取る。

Read `src/shorts/<short-id>/README.md` for context if present, then develop the plot following the loaded dialogue rules.

Confirm the overwrite with the author when `src/shorts/<short-id>/plot.md` exists, then write the file by the loaded rules with this one command, leaving out the options that stay empty: `.agents/refs/plot-skeleton.sh src/shorts/<short-id>/plot.md --body <text> --intent <text> --length <text> --prohibited <text> --highlights <text> --references <text>`
