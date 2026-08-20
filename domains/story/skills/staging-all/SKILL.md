---
name: staging-all
description: Run the scene staging check in parallel on every .txt file in a directory. Use when the user asks to staging-check all files in a directory (e.g. "全ファイルにstagingチェックして").
---

Run `.agents/skills/staging-all/refs.sh`

Run `.agents/skills/staging-all/scripts/files.sh <the directory or file path the user gave>`

Launch one Agent per printed file in parallel. Each agent's prompt contains its file path and the instruction to run `.agents/skills/staging-all/refs.sh` and apply the loaded rules to its file alone.

Aggregate the reports in the printed order, grouped by file.

Run `.agents/skills/staging-all/scripts/save.sh <the same path the user gave>` with the aggregated report on stdin.

Ask via `AskUserQuestion` which findings to fix — options (multiSelect): 「すべて修正」 first, then the top 3 findings in priority order.

Send via `SendMessage` to each touched file's checking agent: its selected findings and the instruction to edit its file, re-check the edited scenes against the loaded rules once, and report what was fixed and what remains. Report the agents' results.
