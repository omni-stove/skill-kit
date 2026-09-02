---
name: load
description: Read the given files in full and hold them as context for later work, replying only that they are read. Use when the user hands over a plot, chapters, or notes to understand before a separate task, with no output wanted yet (e.g. "これ読んで理解しといて", "把握だけして", "load these").
---

The user provides one or more file paths, or text pasted into the prompt. Read every file end to end, continuing past any truncation until the last line; treat pasted text as one document.

Hold what the files establish — who, what has happened, where things stand, and the wording and tone in use.

Reply with a single line confirming what was read, naming the files. No summary, no impressions, no questions.
