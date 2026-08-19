---
name: dupcheck-all
description: Run dupcheck on all .txt files in the target directory in parallel using Agent tools, including boundary-crossing overlap between adjacent files. Use when the user wants a repetition/重複表現 check across every .txt file in a directory at once.
---

Run `.agents/skills/dupcheck-all/refs.sh`

Run `.agents/skills/dupcheck-all/scripts/pairs.sh <the directory or file path the user gave>` — it prints one `file<TAB>next` line per target file, `-` as next for the last one.

Launch one Agent per printed line in parallel. Each agent's prompt contains its file, its next file (if not `-`), and the instruction to read `.agents/refs/dupcheck-rules.md` and follow it exactly. Each agent:

- Reads both files in full, paginating if a read is partial.
- Detects overlap within its file.
- Detects boundary-crossing overlap between the tail of its file and the head of the next file, tagging those findings with the file names.

Aggregate the reports in the printed order and ask which findings to fix per the loaded Fix Flow. Never edit the files yourself. Assign each selected finding to one file — for a cross-file pair, the side to rewrite — and launch one Agent per touched file in parallel. Each agent's prompt contains its `pairs.sh` line, the findings assigned to it, and the instruction to read `.agents/refs/dupcheck-rules.md` and carry out the Fix Flow's edit and re-check steps on its file. Report the agents' results.
