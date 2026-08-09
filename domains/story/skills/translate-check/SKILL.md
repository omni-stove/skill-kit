---
name: translate-check
description: Cross-check an existing English translation against its Japanese source, in both directions. Accepts a source file, a translation file, or a directory. Use when the user wants a finished translation verified (e.g. 「翻訳をチェックして」, "check the translation against the source").
---

Run `.agents/skills/translate-check/refs.sh`

The user provides a path on either side of a pair — a Japanese source file, its `en/` translation, or a directory of sources. Pair each source with its translation; list unpaired files on both sides in the report.

Launch parallel Agent tools — one agent per pair, each given both file paths, the glossary, and the loaded rules. Each agent checks every dimension of the loaded check rules.

For a directory, after the pair agents complete, compare their glossary findings across files and flag any term rendered differently in different files.

Output per pair, one section per dimension of the loaded check rules:

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

Report every finding with line numbers and stop.
