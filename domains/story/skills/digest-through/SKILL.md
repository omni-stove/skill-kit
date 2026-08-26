---
name: digest-through
description: Digest every file in a directory, one at a time, in plain prose. Use when the user wants a file-by-file factual digest of a whole directory.
---

Run `.agents/skills/digest-through/scripts/next.sh <the file path the user gave>` and carry out the action it prints. Repeat until it prints `ALL_DONE`.

Each digest covers who, what happens, and the ending state — prose only, no evaluation. Use only what the file itself shows.

If a later file reveals an earlier digest was wrong, add a one-line correction naming the earlier file and what changed. Don't rewrite the original digest.

The overall understanding covers the through-line, main characters, and what the story is doing, reflecting any corrections.

Output the record path and the overall understanding.
