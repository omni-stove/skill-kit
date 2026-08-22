---
name: read-through
description: Read all .txt files in the same directory as the specified file, one at a time. Use when the user wants every file in a directory read sequentially with a per-file impression (e.g. "通読して", "read through this directory").
---

Run `.agents/skills/read-through/refs.sh`

Repeat until `ALL_DONE`, one script per Bash call — never fold the cycle into a single command or shell loop:

Run `.agents/skills/read-through/scripts/next.sh <the file path the user gave>`

Read the printed file — only ever the file `next.sh` printed; if the result is partial, paginate until the whole file is read.

Run `.agents/skills/read-through/scripts/done.sh <printed file>` with that file's impression, written applying the loaded rules, on stdin.

On `ALL_DONE`, run `.agents/skills/read-through/scripts/summary.sh <the file path the user gave>` with an overall summary, written without restating the per-file impressions, on stdin.

Output the printed record path and the summary.
