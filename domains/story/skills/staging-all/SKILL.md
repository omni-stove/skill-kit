---
name: staging-all
description: Run staging check in parallel on all .txt files in the same directory as the specified file. Use when the user asks to run a scene staging / description-quality check across every .txt file in a directory (e.g. "全ファイルにstagingチェックして").
---

Run `.agents/skills/staging-all/refs.sh`

The user provides a file path. Resolve its parent directory as the target directory. Glob all `.txt` files in that directory (excluding synopsis) and sort them lexically. Launch one Agent per file in parallel.

Each agent:

- Reads only its assigned file.
- Identifies scene boundaries within the file.
- Detects scene-level description quality issues per scene.
- Returns a per-file report prefixed with the file name.

Include in each agent's prompt the instruction to read `.agents/refs/staging-rules.md` and follow it exactly.

After all agents finish, aggregate reports into a single consolidated output, applying the loaded rules exactly. Group findings by file in lexical order. Append a global summary table at the end.

Do NOT use `AskUserQuestion`. Do NOT fix anything. Just output the aggregated report and stop.
