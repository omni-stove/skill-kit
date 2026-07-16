---
name: unnatural
description: Detect unnatural Japanese expressions at the lexical and syntactic levels. Use when the user asks to check a Japanese fiction file or directory for unnatural wording/syntax (不自然な日本語) in narration.
---

The user provides a file path or a directory path:

- **File path**: check only that single file, inline (no Agent dispatch).
- **Directory path**: glob all `.txt` files (sorted naturally) and launch parallel Agent tools for **ALL** matched files, passing each agent its file path and the check items.

**Scope: narration only.** Skip everything inside 「」 (dialogue) entirely — do not flag, do not suggest fixes, do not even read it as part of the check target.

Check items — lexical level:

- **Collocation violations**: word combinations that do not co-occur (e.g. 「微笑を吐く」「努力を浴びる」)
- **Misuse of idioms / four-character compounds**: wrong meaning or distorted form (e.g. 「的を得る」「汚名挽回」)
- **Pleonasm (重ね言葉)**: redundant meaning (e.g. 「馬から落馬」「頭痛が痛い」「後で後悔」)
- **Register mismatch**: clashes of formal/informal, archaic/modern, literary/colloquial within one passage
- **Redundant modification**: stacking synonymous modifiers (e.g. 「真っ赤な紅蓮の炎」)
- **Semantic misuse**: wrong meaning of Sino-Japanese or katakana words (e.g. 「役不足」used to mean 「力不足」)

Check items — syntactic level:

- **Subject-predicate mismatch (ねじれ文)**: subject and predicate do not logically correspond
- **Broken modifier–head relations**: ambiguous or twisted modifier scope
- **Overly long adnominal modification**: deeply nested 連体修飾節 that strains parsing
- **Uneven parallel structure**: 「A and B」 not aligned in part of speech, abstraction, or granularity
- **Case particle misuse**: wrong choice of 「を/が/に/へ」 etc.
- **Unnecessary double negation**: double negation where a simple form would do
- **Tense / aspect twist within a single sentence**: inconsistent 「〜した／〜している／〜する」 inside one sentence (cross-paragraph drift is out of scope)
- **Confused passive / causative**: wrong agent attribution that breaks the meaning

Out of scope:

- Typos and paragraph-level tense consistency
- Synonymous repetition / near-duplicate expressions
- Mechanical notation rules detectable by textlint
- Intentional stylistic choices in narration (体言止め, inversion, varying sentence length, narrator's idiosyncrasy, deliberate stylistic deviation)
- **Personification, metaphor, and other figures of speech (擬人法・比喩・修辞)** — never treat an inanimate/abstract subject + active verb, or a figurative collocation, as an error. These are intentional by default. When tempted to flag a 主述のねじれ or コロケーション違反, first ask "is this a deliberate figure of speech?" — only report when the figure genuinely fails to parse (true contradiction), not merely because it is non-literal.

After the check (or all agents) complete, display the results (combined if multiple files) in this format:

```markdown
# Unnatural Expression Check

## Target
[file path]

## Results

### High
#### 1. [Category: type] (e.g. Syntactic: subject-predicate mismatch)
- **L[line]**: 「[quoted passage]」
- **Issue**: [why it is unnatural — 1–2 lines]
- **Suggested fix**: [alternative phrasing]

### Medium
#### 1. ...

### Low
#### 1. ...
```

Severity criteria:

- **High**: clear misuse or breakdown. Most readers will stumble.
- **Medium**: noticeable awkwardness but readable. Issues of register or flow.
- **Low**: acceptable but improvable. Closer to a matter of taste.

For borderline cases, report as Low with a 「要確認」 tag and keep the suggested fix tentative. If the same issue recurs many times, report the first few in detail and mention the remaining count only. If nothing is found, output only `問題なし`.

If issues are found, confirm via AskUserQuestion — 質問:「修正する項目を選んでください」, options (multiSelect, max 4): 「すべて修正（深刻度: 高・中）」 first, then the top 3 High items in priority order. For selected items, edit the target file(s) directly to apply the fixes.
