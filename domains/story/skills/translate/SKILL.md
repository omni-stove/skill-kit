---
name: translate
description: Translate an existing Japanese manuscript into English. Accepts a file or a directory. Use when the user asks to render a Japanese story file into English (e.g. 「英訳して」, "translate this into English").
---

Run `.agents/skills/translate/refs.sh`

Run `.agents/refs/translation-pairs.sh <path>` on the user's path.

Read the glossary. If it does not exist, settle the work-wide decisions with a single `AskUserQuestion` call: name romanization scheme, honorifics (keep as-is / drop / adapt), and register (web-novel casual / literary).

Translate each printed source to its printed translation path. For a directory, launch parallel Agent tools — one agent per source, each given both paths, the glossary, and the loaded rules. Never modify the source.

Before translating a file, list its deliberately repeated words and images and hold one rendering for each. Where the source leaves a subject genuinely ambiguous, pick the most likely reading and flag it.

After translating each file, run two review agents. One gets only the English file and reports each passage it stumbles on or misreads — line and its own reading, no fixes; rewrite from the source wherever that reading diverges. The other runs over the loaded check rules with both files; apply its fixes, checking English-only ones against the source.

For a directory, run one agent per adjacent file pair to align shared expressions and motif renderings.

Update the glossary with new names and any new work-wide decision.

Report: files written, glossary entries added, review fixes applied, and flagged passages with line numbers.
