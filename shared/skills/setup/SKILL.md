---
name: setup
description: Adapt the kit to this repo by generating this repo's real .agents/refs files (a per-project layout file per project, and for the game domain engine.sh) whose functions return this repo's actual paths / engine facts. Use when setting up skill-kit in a repo — a new repo, a non-default engine, or a repo laid out differently from the kit default (e.g. "setup", "このリポジトリ用に設定して", "layoutを合わせて", "Godot用に合わせて").
---

Run `.agents/skills/setup/refs.sh` — it prints this repo's **domain** (game or story) and the
domain-specific setup rules for that domain. Everything specific to what you generate — which
override files, which functions, how to detect the engine/layout, how to verify — lives in the
loaded rules. Read them in full, then follow them exactly; treat them as the contract.

The house rules that always apply, regardless of domain:

- The kit's `.agents/refs/*.sh` defaults are the contract you adapt: the function NAMES are
  fixed, only the values they echo change for this repo.
- You produce **real** files in `.agents/refs/`. `skill-kit <domain> sync` leaves real files
  untouched and keeps them git-tracked, so a real override wins over the kit's symlinked
  default. Do NOT edit a symlink target, and never hand-build paths or engine facts anywhere
  else — every value a skill uses comes from these functions.
- If `.agents/refs/domain` does not exist, the kit was never synced here — tell the user to run
  `skill-kit {game|story} sync` first, then stop.

Follow the loaded rules to detect this repo's real layout, generate the overrides, verify the
resolved values, and end with `git status` confirming the override files show as real, tracked
files (not ignored) and nothing else changed.
