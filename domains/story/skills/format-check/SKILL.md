---
name: format-check
description: Check write output against japanese-web-novel-format rules and report only lines with issues. Use when the user wants a single file checked against Japanese web novel formatting conventions.
---

Run `.agents/skills/format-check/refs.sh`

The user provides the path to the target file to check.

Run `.agents/refs/format.sh <target file>`

Read the target file and check all rules in the loaded format reference, starting from the listed lines. Report only lines with issues — line number and short quote. If clean: "No issues found." If issues found, ask whether to fix.
