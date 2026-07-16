---
name: read-through
description: Read all files in the same directory as the specified file, one at a time. Use when the user wants every file in a directory read sequentially with a per-file impression (e.g. "通読して", "read through this directory").
---

Run `.agents/skills/read-through/refs.sh`

Repeat until `ALL_DONE`:

Run `.agents/skills/read-through/scripts/next.sh <the file path the user gave>` — it prints the next unprocessed file in that file's directory with its line count, or `ALL_DONE` once every file is processed.

Read the printed file; if the result is partial, paginate until the whole file is read.

Output that file's impression applying the loaded rules — always before the next Read.

Run `.agents/skills/read-through/scripts/done.sh <printed file>` — it records the file as processed.

On `ALL_DONE`, output an overall summary.
