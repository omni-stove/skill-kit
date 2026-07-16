---
name: layman
description: Evaluate text from a layman's perspective, flagging passages that require specialist knowledge. Accepts a file or a directory. Use when the user asks whether a non-expert reader can follow a story file or directory and wants specialist-knowledge barriers flagged.
---

Read as a reader with zero specialist knowledge. Flag only the passages a layman cannot follow. Suggest rewrites only when asked. Apply only after approval.

The user provides a file path or a directory path as the target. For a file, evaluate that file. For a directory: list files (natural sort, skip synopsis), `wc -l`, then loop sequentially — Read → evaluate → next. No batching, no parallel. Do not end the turn until every file is processed.

Do **NOT** consult project settings, character files, or world-building documents. Judge only from the text itself.

Stance: zero domain knowledge (medicine, aerospace, law, military, IT, etc.), high-school common sense only. Skip anything readable without specialist knowledge, and skip passages that work as atmosphere even if technically opaque.

Flag: specialist terms without explanation, opaque acronyms/loanwords, implicit prerequisite knowledge, insider procedures, uncontextualized numbers/units, unexplained industry conventions. For each: line number, quoted passage, what blocks comprehension, impact on the reader.

Per-file output:

```markdown
# Layman Evaluation — <filename>

## Overall
<one line>

## Hard passages
### L<line>「<quoted passage>」
- Blocks: <reason>
- Impact: <consequence>
```

If nothing to flag:

```markdown
# Layman Evaluation — <filename>
No layman-blocking passages.
```

Directory wrap-up output:

```markdown
# Overall Summary
- Hardest files: <list>
- Recurring opaque terms: <list>
- Cross-file patterns: <list>

Reply "suggest [filename]" for rewrite proposals.
```

Rewrite flow (only when the user asks): `suggest [filename]` → produce rewrite proposals; `approve [numbers]` → edit the file in place and report changed lines. Do not touch unapproved passages.

Rewrite proposal output:

```markdown
## Rewrite proposals — <filename>

### <n>. L<line>
Original: 「<quoted passage>」
Proposal: 「<rewritten passage>」
Reason: <justification>

Reply "approve" to apply, or "approve <numbers>" for a subset.
```

Stay honest. No fake confidence, no hedging that pretends to understand.
