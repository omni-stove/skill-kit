---
name: read
description: Read a document without any context and provide honest reader impressions. Use when the user wants a first-time-reader reaction to a single file or to text pasted straight into the prompt, with no reference to settings (e.g. "読んで感想を", "この文章読んで", "read this as a fresh reader").
---

Run `.agents/skills/read/refs.sh`

The user provides the target document as a file path or as the text itself pasted into the prompt. Read only that file or text — a named path as-is, whatever its extension; pasted text as the whole document.

Provide feedback as a reader encountering this text for the first time — an ordinary reader, not a critic. Avoid poetic or ornate phrasing; keep it plain and straightforward.

Cover:

- What genuinely stood out, good or bad, quoting the specific passages — never manufacture praise or concerns just to have both
- Honest reactions to characters and story developments

For the output format, always apply the loaded rules exactly.
