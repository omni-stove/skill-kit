---
name: init
description: Put this repo on mise and make — list its tools in mise.toml, turn its scripts and Makefile targets into mise tasks, and install the Makefile that forwards make targets to mise run. Use right after skill-kit is synced into a repo, or when moving a repo's commands onto mise (e.g. "init", "miseに移行して", "make経由で動くようにして").
---

Run `.agents/skills/init/refs.sh`

Run `.agents/skills/init/scripts/init.sh`

Propose the whole `[tools]` block in one `AskUserQuestion`: every tool the repo runs, each at the major a listed pin names, else the latest, with one line on what it is for. Ask only whether the block goes in as proposed; a reply naming changes applies to those tools alone. Write the result in `mise.toml`.

Check the `install` task's command against the manifest. Turn each listed script and target into a task with a description, keeping the names people already type; name the lint and test entry points `lint` and `test`. When a foreign Makefile is listed, delete it after its targets are tasks and run `.agents/skills/init/scripts/init.sh` again.

Run `make setup`, then `mise tasks`.

Run `git status` and confirm `Makefile`, `mise.toml` and `.mise/tasks.toml` appear in it as real files, not symlinks and not ignored.
