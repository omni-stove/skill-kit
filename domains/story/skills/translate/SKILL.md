---
name: translate
description: Translate an existing Japanese manuscript into English. Accepts a file or a directory. Use when the user asks to render a Japanese story file into English (e.g. 「英訳して」, "translate this into English").
---

Run `.agents/skills/translate/refs.sh`

The user provides a file path or a directory path. For a file, translate that file. For a directory, launch parallel Agent tools — one agent per source file, each given its file path, the glossary, and the loaded rules.

Write each translation to its `en/` path. Never modify the source.

Read the glossary before translating. If it does not exist, settle the work-wide decisions first with a single `AskUserQuestion` call: name romanization scheme, honorifics (keep as-is / drop / adapt), and register (web-novel casual / literary). After translating, create or update the glossary with every new decision and motif.

Before translating a file, list its deliberately repeated words and images and check each against the glossary's Motifs section. Where the source leaves a subject genuinely ambiguous, pick the most likely reading and flag it.

After translating each file, run review agents over the loaded check rules — one for the English-only dimension, one for the rest — and apply their fixes. Apply an English-only fix only after it is checked against the source.

For a directory, after review, run one agent per adjacent file pair to align shared expressions and motif renderings to the glossary.

Report: files written, glossary entries added, review fixes applied, and flagged passages with line numbers.
