---
name: dupcheck-all
description: Detect semantically overlapping expressions across every .txt file in a directory, including overlap that crosses files. Use when the user wants a repetition/重複表現 check over a whole directory at once.
---

Run `.agents/skills/dupcheck-all/refs.sh`

Run `.agents/skills/dupcheck-all/scripts/bundle.sh <the directory or file path the user gave>`

Read the printed bundle through to its printed line count, continuing from where each read stops. Detect the overlap across the whole of it — within one file and between any two, however far apart — quoting each expression without its line prefix.

Apply the loaded fix flow with the whole bundle still in view, editing the source files the prefixes name.
