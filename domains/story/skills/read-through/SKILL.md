---
name: read-through
description: Read all .txt files in the same directory as the specified file, one at a time. Use when the user wants every file in a directory read sequentially with a per-file impression (e.g. "通読して", "read through this directory").
---

Run `.agents/skills/read-through/refs.sh`

Repeat until `ALL_DONE`, one script per Bash call — never fold the cycle into a single command or shell loop:

Run `.agents/skills/read-through/scripts/next.sh <the file path the user gave>` — it prints the next unprocessed `.txt` file in that file's directory with its line count, or `ALL_DONE` once every file is processed.

Read the printed file — only ever the file `next.sh` printed; if the result is partial, paginate until the whole file is read.

Run `.agents/skills/read-through/scripts/done.sh <printed file>` with that file's impression, written applying the loaded rules, on stdin — it appends the impression to this run's record and prints the record path.

On `ALL_DONE`, output the record path and an overall summary without restating the per-file impressions.
