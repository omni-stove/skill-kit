---
name: timeline
description: Arrange the events the user describes into in-world chronological order and render them as a Mermaid event-node diagram, BEFORE the body is written. Takes a project id (for the output path) and a free-form description of the events. Uses only the events given — adds nothing. Use when the user wants to lay out the chronological flow of events (時系列の流れ) as a blueprint for writing, not to extract a timeline from existing prose.
---

Arrange the events the user describes into the order they **happen in the story world** and render them as a Mermaid event-node diagram. It is a pre-writing blueprint built before the body text. How each event is narrated (order, perspective, flashback) is decided later when writing; the timeline holds events in chronological order only.

The user specifies a **project id** (for the output path only) and a **free-form description** of the story's events. Build the timeline **solely from that description** — do not read project files (README, plot, synopsis, settings).

Take the events exactly as the free-form description gives them — add nothing, drop nothing, invent no connective beats or backstory. Sort them into the order they happen in the story world; where the order is ambiguous, follow the order the description itself implies.

Produce a `flowchart TD` whose **nodes are events**, top-to-bottom in chronological order:

- One node per event. The label holds the event itself (no timestamps) — descriptive enough to stand alone.
- Number nodes in sequence order.
- Use solid arrows `-->` for direct succession (next event in order / causal next).
- Branch nodes for concurrent or parallel events; use a `subgraph` per phase.
- Wrap node labels in double quotes and avoid raw parentheses / colons inside unquoted labels.

Get the output path from `.agents/refs/path <project-id> story_timeline` and use the line it prints; never hand-build it. Do not read any other project files. Write to that path (overwrite if it exists):

```markdown
# [project-id] タイムライン

## イベントフロー（Mermaid）

​```mermaid
flowchart TD
    E1["① 出来事の内容"]
    E2["② 出来事の内容"]
    E3["③ 出来事の内容"]
    E1 --> E2 --> E3
​```
```
