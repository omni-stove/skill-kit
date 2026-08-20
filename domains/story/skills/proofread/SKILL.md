---
name: proofread
description: Proofread story text for typos, tense confusion, and notation variance. Use when the user asks to proofread a file or directory (e.g. "校正して", "proofread this file").
---

Run `.agents/skills/proofread/scripts/files.sh <the file or directory path the user gave>`

Launch one Agent per printed file in parallel, passing the file path and the items below.

- Typos — homophone conversion mistakes, okurigana errors, dropped or duplicated particles, missing or extra characters, misspelled katakana words
- Tense confusion (narration only) — flashback or exposition indistinguishable from the present scene, event order unfollowable because of tense. Do not report mere mixing of た-form and る-form
- Notation variance — the same word in both kanji and hiragana, inconsistent proper-noun spelling
- Do not report intentional expression such as speech quirks or dialect

Run `.agents/skills/proofread/scripts/save.sh <the same path>` with the combined results on stdin.

Ask whether to fix any problems.
