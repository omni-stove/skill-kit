---
name: dupcheck-all
description: Detect semantically overlapping expressions across every .txt file in a directory, including overlap that crosses adjacent files. Use when the user wants a repetition/重複表現 check over a whole directory at once.
---

Run `.agents/skills/dupcheck-all/refs.sh`

Run `.agents/skills/dupcheck-all/scripts/pairs.sh <the directory or file path the user gave>` — it prints each target file with the file that follows it.

Launch one Agent per printed line in parallel. Each agent's prompt contains its line and the loaded rules, and has it detect overlap within its own file and overlap between that file's tail and the next file's head, tagging the crossing findings with both file names, and report without editing.

Aggregate the reports in the printed order. Never edit the files yourself. Assign each High and Medium finding to one file — for a cross-file pair, the later one — and continue each touched file's agent via SendMessage with its findings to fix.

Then launch one Agent per edited file in parallel, each given its file, the file before it, and the loaded rules, to read the file whole against its diff and restore any line where the content moved.

Report the fixes and the restorations together.
