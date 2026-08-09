---
name: translate
description: Translate an existing Japanese manuscript into English. Accepts a file or a directory. Use when the user asks to render a Japanese story file into English (e.g. 「英訳して」, "translate this into English").
---

Run `.agents/skills/translate/refs.sh`

The user provides a file path or a directory path. For a file, translate that file. For a directory, glob its `.txt` and `.md` files (natural sort, skip synopsis) and launch parallel Agent tools — one agent per file, each given its file path, the glossary, the loaded rules, and the translation rules below.

Write each translation to `en/<same filename>` inside the source's directory. Never modify the source.

Read `en/glossary.md` before translating and give it to every agent. If it does not exist, settle the work-wide decisions first with a single `AskUserQuestion` call: name romanization scheme, honorifics (keep as-is / drop / adapt), and register (web-novel casual / literary). After translating, create or update `en/glossary.md` with name romanizations, recurring term renderings, style decisions, and a Motifs section: one `語 → rendering` line per motif expected to echo beyond its own file.

Translation rules:

- Translate for meaning and voice.
- Keep every scene break, the order of events, and the intent of each paragraph.
- Render wordplay by effect. Add nothing, omit nothing.
- Resolve subjects and pronouns Japanese leaves implicit; when the source is genuinely ambiguous, pick the most likely reading and flag it.
- Before translating, list the source's deliberately repeated words and images — a word recurring at structural moments, an image that returns transformed — and check each against the glossary's Motifs section.
- Keep `POV:` lines and 【】 markers verbatim: manuscript scaffolding, not prose.

After translating each file, run two review agents:

1. English-only review: reads the English without the source and flags translationese — syntax showing through, filter phrases, monotone rhythm.
2. Fidelity review: compares source and translation and flags additions, omissions, and thinned repetition. Apply an English-only fix only after this pass checks it against the source.

For a directory, after review, run one agent per adjacent file pair to align shared expressions and motif renderings to the glossary.

After all agents complete, report: files written, glossary entries added, review fixes applied, and flagged passages with line numbers.
