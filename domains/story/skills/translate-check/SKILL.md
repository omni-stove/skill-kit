---
name: translate-check
description: Cross-check an existing English translation against its Japanese source, in both directions. Accepts a source file, a translation file, or a directory. Use when the user wants a finished translation verified (e.g. 「翻訳をチェックして」, "check the translation against the source").
---

Run `.agents/skills/translate-check/refs.sh`

The user provides a path on either side of a pair — a Japanese source file, its English translation under `en/`, or a directory of sources. Each pair is a source file and `en/<same filename>` in the source's directory. For a directory, glob its `.txt` and `.md` files (natural sort, skip synopsis) and pair each; list unpaired files on both sides in the report without checking them.

Read `en/glossary.md` if it exists and give it to every agent.

Launch parallel Agent tools — one agent per pair, each given both file paths, the glossary, and the loaded rules. Each agent checks every dimension of the loaded check rules.

For a directory, after the pair agents complete, compare their glossary findings across files and flag any term rendered differently in different files.

Output per pair:

```
## Translation Check: <filename>

### Fidelity
- 🔴 (src:N / en:M) — [detail]

### English Quality
- 🟡 (en:M) — [detail]

### Glossary / Motifs
- 🟠 [term] — [detail with locations]

### Verified (No Issues)
- ✅ [Summary of checked items]
```

Severity criteria:

- 🔴 **Fidelity**: meaning changed, content added or omitted, events reordered, motif repetition broken
- 🟡 **English quality**: translationese, rhythm, style-rule violations
- 🟠 **Glossary**: renderings inconsistent with the glossary or across files

Report all findings mechanically with line numbers. Do NOT use `AskUserQuestion` or ask for confirmation. Do NOT fix anything and never modify any file. Just output the report and stop.
