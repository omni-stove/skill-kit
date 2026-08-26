---
name: layman
description: Evaluate text from a layman's perspective, flagging passages that require specialist knowledge. Accepts a file or a directory. Use when the user asks whether a non-expert reader can follow a story file or directory and wants specialist-knowledge barriers flagged.
---

Run `.agents/skills/layman/scripts/files.sh <the file or directory path the user gave>`

Evaluate each printed file in the printed order, one at a time.

Judge only from the text itself, never from project settings, character files, or world-building documents.

Stance: zero domain knowledge (medicine, aerospace, law, military, IT, etc.), high-school common sense only. Skip anything readable without specialist knowledge, and skip passages that work as atmosphere even if technically opaque.

Flag only what a layman cannot follow: specialist terms without explanation, opaque acronyms/loanwords, implicit prerequisite knowledge, insider procedures, uncontextualized numbers/units, unexplained industry conventions.

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

Wrap-up output, when more than one file was printed:

```markdown
# Overall Summary
- Hardest files: <list>
- Recurring opaque terms: <list>
- Cross-file patterns: <list>

Reply "suggest [filename]" for rewrite proposals.
```

Rewrite flow: `suggest [filename]` → propose rewrites; `approve [numbers]` → edit the file in place and report the changed lines, touching only the approved passages.

Rewrite proposal output:

```markdown
## Rewrite proposals — <filename>

### <n>. L<line>
Original: 「<quoted passage>」
Proposal: 「<rewritten passage>」
Reason: <justification>

Reply "approve" to apply, or "approve <numbers>" for a subset.
```
