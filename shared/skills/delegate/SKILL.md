---
name: delegate
description: Split a task too large for one session into issues for the remote issue worker, with the steps only the user can do as manual issues.
---

Take the task from the argument and the decisions already made in the conversation. Settle an open point yourself.

Read the code the task changes and list the files each item would change, including the schema, migrations, generated types, dependency manifests, registries, config and message catalogs every change appends to.

Split the task into issues that can be implemented in parallel, each touching files no other issue touches. When two lists share a file, open the split with an `implementation` issue that, without changing behavior, makes every change the task needs to the shared files, splits a file the later changes would edit in the middle, and adds the types, signatures and extension points they plug into. Every other issue that changes code waits on it.

An issue that still touches a file another issue touches, or depends on another's result, waits on it, and is filed now too.

Label each issue: `bug` fixes existing behavior, `implementation` is new work at production quality with real data access, error handling and tests. `manual` is a step only the user can do on their own machine, by hand or with computer use. Size an `implementation` issue to about an hour of work, a `bug` to about half an hour.

Write each issue's task as what to do and its check as how a person confirms it done by hand. A `manual` issue's task is the steps the user takes.

Run `.agents/skills/delegate/scripts/similar.sh <keywords from the task>...`

Run `.agents/skills/delegate/scripts/parent.sh "<title>" "<body>"`, or `.agents/skills/delegate/scripts/parent.sh --issue <number> "<body>"` when the conversation points at an existing issue as the task's origin. The body holds the goal, the decisions, and how the work was split with the files each issue changes.
