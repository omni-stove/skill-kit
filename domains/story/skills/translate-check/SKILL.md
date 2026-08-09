---
name: translate-check
description: Cross-check an existing English translation against its Japanese source, in both directions. Accepts a source file, a translation file, or a directory. Use when the user wants a finished translation verified (e.g. 「翻訳をチェックして」, "check the translation against the source").
---

Run `.agents/skills/translate-check/refs.sh`

Run `.agents/refs/translation-pairs.sh <path>` on the user's path. List `source-only` and `en-only` lines in the report.

Launch parallel Agent tools — one agent per `pair` line, each given both file paths, the glossary, and the loaded rules.

For a directory, compare the agents' consistency findings and flag any term rendered differently across files.

Output per pair:

```
## Translation Check: <filename>

### Fidelity
- 🔴 (src:N / en:M) — [detail]

### English Quality
- 🟡 (en:M) — [detail]

### Consistency
- 🟠 [term] — [detail with locations]

### Verified (No Issues)
- ✅ [Summary of checked items]
```

Report every finding and stop.
