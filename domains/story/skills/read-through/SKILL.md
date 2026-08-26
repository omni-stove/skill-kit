---
name: read-through
description: Read all .txt files in the same directory as the specified file, one at a time. Use when the user wants every file in a directory read sequentially with a per-file impression (e.g. "通読して", "read through this directory").
---

Run `.agents/skills/read-through/refs.sh`

Run `.agents/skills/read-through/scripts/next.sh <the file path the user gave>` and carry out the action it prints. Repeat until it prints `ALL_DONE`.

Output the record path and the summary.
