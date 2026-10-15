---
name: translate
description: Translate an existing Japanese manuscript into English. Accepts a file or a directory. Use when the user asks to render a Japanese story file into English (e.g. 「英訳して」, "translate this into English").
---

Run `.agents/skills/translate/refs.sh`

Run `.agents/refs/translation-pairs.sh <the path the user gave>`

If the glossary is missing, settle the work-wide decisions with a single `AskUserQuestion` call: name romanization scheme, honorifics (keep as-is / drop / adapt), and register (web-novel casual / literary).

Translate each source to its translation path — for a directory, one parallel Agent per source, each given both paths, the glossary, and the loaded rules. Never modify the source. Where the source leaves a subject genuinely ambiguous, pick the most likely reading and flag it.

After each file, run a review agent over the loaded check rules with both files; apply its fixes, checking English-only ones against the source.

Then have an agent on the lowest available model read the English alone and report each passage it stumbles on or misreads — line and its own reading, no fixes. Rewrite from the source wherever that reading diverges from it.

For a directory, run one agent per adjacent file pair to align shared expressions and motif renderings.

Add new names and work-wide decisions to the glossary.

Report: files written, glossary entries added, review fixes applied, and flagged passages with line numbers.
