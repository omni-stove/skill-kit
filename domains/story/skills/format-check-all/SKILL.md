---
name: format-check-all
description: Run format-check on all .txt files in the target directory in parallel using Agent tools. Use when the user wants every .txt file in a directory checked against the Japanese web novel format rules at once.
---

The user provides a target directory. Glob all `.txt` files in it and launch one Agent per file in parallel.

Include in each agent's prompt the instruction to read `.agents/refs/japanese-web-novel-format.md`, check its file against all rules in it, and report only lines with issues — line number and short quote; if clean, "No issues found."

After all agents finish, display the combined results. If issues found, ask whether to fix.
