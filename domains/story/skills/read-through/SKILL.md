---
name: read-through
description: Read all .txt files in the same directory as the specified file, one at a time. Use when the user wants every file in a directory read sequentially with a per-file impression (e.g. "通読して", "read through this directory").
---

Run `.agents/skills/read-through/refs.sh`

Repeat until `ALL_DONE`:

Run `.agents/skills/read-through/scripts/next.sh <the file path the user gave>` — it prints the next unprocessed `.txt` file in that file's directory with its line count, or `ALL_DONE` once every file is processed.

Read the printed file — only ever the file `next.sh` printed; if the result is partial, paginate until the whole file is read.

Output that file's impression applying the loaded rules.

Run `.agents/skills/read-through/scripts/done.sh <printed file>` with that impression on stdin — it rejects an empty impression, records the file as processed, and appends the impression to the run's record.

On `ALL_DONE`, output an overall summary.
