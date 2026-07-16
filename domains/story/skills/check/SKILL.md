---
name: check
description: Check a story file for contradictions and inconsistencies across settings and adjacent files. Use when the user wants to verify a story file for continuity, physical-state, or setting contradictions and names a target file.
---

The user specifies the target story file path to check.

Get each path from `.agents/refs/path <project-id> <what>`; never hand-build one. `<what>`: `readme`, `characters` (the dir).

Read the target file and determine its number (e.g., `005.txt` → 5). Extract the project ID from the path and read the `readme` path. Read the previous and next files if they exist — only the ending ~50 lines of the previous file and the opening ~50 lines of the next file are needed. Identify characters appearing in the target file and read their character files from the `characters` directory. If an architecture or trick file is referenced or exists for the current story arc, read it as well.

Check the boundary between the previous file's ending and the target file's opening:

- **Character presence**: Who was present at the end of the previous file? Does the opening of the target file account for them?
- **Location**: Where were characters at the end of the previous file? Does the target file's opening location match or show a transition?
- **Physical state**: Posture, held objects, clothing, injuries, emotional state — do they carry over correctly?
- **Time continuity**: Does time of day / scene transition make sense?
- **Unresolved actions**: If the previous file ended mid-conversation or mid-action, does the target file pick it up or explain the gap?

Do the same check for the boundary between the target file's ending and the next file's opening.

Then read through the text sequentially and track the physical state of every character present in each scene. For each character in each scene, mentally maintain: position, posture, facing direction, held items, clothing state. When an action changes state, verify the prior state allows it. Flag contradictions such as:

- **Posture**: sitting down when already seated, standing up when already standing
- **Location**: being in a place they never moved to, or leaving a place they already left
- **Held objects**: using an object they put down or never picked up, holding something in a hand that's already occupied
- **Doors/containers**: opening what's already open, closing what's already closed
- **Clothing/equipment**: putting on what's already worn, removing what's already removed

Check the target file against project settings:

- **World setting contradictions** (README.md, world/)
- **Character setting contradictions** (characters/) — speech patterns, personality, abilities, relationships
- **Information consistency** — no character uses information they should not know at this point
- **Architecture/trick consistency** — if an architecture or trick file exists, verify plot mechanisms, event sequences, and role assignments match

Output format:

```
## Check Result: [filename]

### Cross-file Issues (← previous file)
- 🔴 (line:N) — [detail]

### Cross-file Issues (→ next file)
- 🔴 (line:N) — [detail]

### Internal Issues
- 🔴 [Physical state contradiction] (line:N) — [detail]
- 🟡 [Minor inconsistency] (line:N) — [detail]
- 🟠 [Behavior/setting deviation] (line:N) — [detail]

### Verified (No Issues)
- ✅ [Summary of checked items]
```

Severity criteria:

- 🔴 **Critical**: Physical state contradictions, cross-file continuity breaks, impossible movement, premature information reveal, architecture/trick violations
- 🟡 **Minor**: Ambiguous but potentially problematic descriptions, slight timeline oddities
- 🟠 **Behavior**: Character speech or actions deviating from established settings

Report all findings mechanically. Do NOT use `AskUserQuestion` or ask for confirmation. Do NOT fix anything. Just output the report and stop.
