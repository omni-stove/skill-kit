---
name: task
description: Add or change a mise task so it runs as `make <name>` (= `mise run <name>`). Use when the user wants a new command in the repo, or an existing script turned into one (e.g. "タスク追加して", "make lint で動くようにして", "add a task for X").
---

Run `.agents/skills/task/refs.sh`

Run `mise tasks`

Write the task in `.mise/tasks.toml`. Add any tool it newly calls under `[tools]` in `mise.toml` and run `mise install`.

Run `mise tasks` and confirm the task is listed. Run `make <name>` when doing so changes nothing the user has not asked for; otherwise tell the user the command to run.
