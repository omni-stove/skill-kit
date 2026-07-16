---
name: dupcheck-all
description: Run dupcheck on all .txt files in the target directory in parallel using Agent tools, including boundary-crossing overlap between adjacent files. Use when the user wants a repetition/重複表現 check across every .txt file in a directory at once.
---

Run `.agents/skills/dupcheck-all/refs.sh`

The user provides a target directory. Glob all `.txt` files in it (excluding synopsis) and sort them lexically. Launch one Agent per file in parallel.

Each agent:

- Reads its assigned file **and the next file** in the sorted list (if any).
- Detects overlap within the assigned file (entire file).
- Detects boundary-crossing overlap between the tail of the assigned file and the head of the next file.
- Tags cross-file findings with the file name.

Include in each agent's prompt the instruction to read `.agents/refs/dupcheck-rules.md` and follow it exactly.

After all agents finish, aggregate reports and run the Fix Flow over the combined findings, applying the loaded rules exactly.
