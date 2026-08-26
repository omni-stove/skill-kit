---
name: format-check-all
description: Check every .txt file in a directory against the Japanese web novel format rules and report the offending lines. Use when the user wants a whole directory format-checked at once.
---

Run `.agents/skills/format-check-all/refs.sh`

Run `.agents/skills/format-check-all/scripts/files.sh <the directory or file path the user gave>`

Launch one Agent per printed file in parallel. Each agent's prompt contains its file and the loaded rules, and has it report only the lines with issues — line number and short quote.

Display the combined results in the printed order. If issues are found, ask whether to fix.
