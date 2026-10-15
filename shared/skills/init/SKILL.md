---
name: init
description: Put this repo on mise and make — list its tools in mise.toml, turn its scripts and Makefile targets into mise tasks, and install the Makefile that forwards make targets to mise run. Use right after skill-kit is synced into a repo, or when moving a repo's commands onto mise (e.g. "init", "miseに移行して", "make経由で動くようにして").
---

Run `.agents/skills/init/refs.sh`

Run `.agents/skills/init/scripts/init.sh`

Propose a major version for every tool the repo runs — the major a listed pin names, else the latest — in one `AskUserQuestion` round, and write what the user settles on under `[tools]` in `mise.toml`.

Make the `setup` task install the repo's dependencies before it installs skill-kit. Turn each listed script and target into a task with a description, keeping the names people already type. When a foreign Makefile is listed, delete it after its targets are tasks and run `.agents/skills/init/scripts/init.sh` again.

Run `make setup`, then `mise tasks`.

Run `git status` and confirm `Makefile`, `mise.toml` and `.mise/tasks.toml` appear in it as real files, not symlinks and not ignored.
