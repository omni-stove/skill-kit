---
name: timeline
description: Arrange the events the user describes into in-world chronological order and write them as a Mermaid event-node diagram. Takes a free-form description of the events. Use when the user wants to lay out the chronological flow of events (時系列の流れ) before writing, not to extract a timeline from existing prose.
---

The user provides a free-form description of the events.

Build the timeline from that description alone; read no project files. Keep exactly the events it gives. Sort them into the order they happen in the story world; where that is ambiguous, follow the order the description implies.

Write a `flowchart TD` whose nodes are the events, top to bottom in chronological order:

- One node per event, numbered in order. The label is the event itself, no timestamp, wrapped in double quotes.
- `-->` from each event to the next.
- Branches for concurrent events; a `subgraph` per phase.

Write to `story/timeline.md`, overwriting:

```markdown
# タイムライン

## イベントフロー（Mermaid）

​```mermaid
flowchart TD
    E1["① 出来事の内容"]
    E2["② 出来事の内容"]
    E3["③ 出来事の内容"]
    E1 --> E2 --> E3
​```
```
