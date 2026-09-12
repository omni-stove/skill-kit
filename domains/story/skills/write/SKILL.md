---
name: write
description: Write story content by specifying a project. Use when the user wants to draft a story scene/chapter from a plot or work-in-progress file for a given project id.
---

Run `.agents/skills/write/refs.sh`

The user provides the project-id and the source.

Run `.agents/skills/write/scripts/source.sh <project-id> <source>`

Write 1 Scene by the loaded rules, with the printed `Source:` line at the top and, only if the project specifies a POV character, a `POV:` line after it. Read character, world, adjacent chapters, and other plots where consistency needs them; the source file leads.

Output the file and hand off:

```
[Scene name] complete. Reply y for the next Scene, or say what to revise.
```

`y` → write the next Scene; anything else → revise the Scene as the input says, then hand off again.
