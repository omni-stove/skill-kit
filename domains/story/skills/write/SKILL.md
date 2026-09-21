---
name: write
description: Write story content from a plot file, or revise a story file. Use when the user wants to draft a story scene/chapter from a plot file, or revise a written story file.
---

Run `.agents/skills/write/refs.sh`

The user provides a file: a plot, or the story file itself.

Run `.agents/skills/write/scripts/source.sh <file>` — it prints the `Source:` line, the output file, and what to do with it.

Launch one Agent on the source file to report what it must stay consistent with and what of it the reader already has, quoting the preceding chapter's opening lines.

Write 1 Scene by the loaded rules, with the printed `Source:` line at the top and, only if the project specifies a POV character, a `POV:` line after it. Open another file only for a fact the report lacks; the source file leads. Deliver its プロットの意図 through events alone. Given the story file itself, revise it as the user says instead.

Output the file. Run `.agents/skills/write/scripts/scene-check.sh <output file>` — it prints the checks to run over the file — then hand off:

```
[Scene name] complete. Reply y for the next Scene, or say what to revise.
```

`y` → write the next Scene; anything else → revise the Scene as the input says, then check and hand off again.
