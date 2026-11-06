# game

Skills for game development on any engine (Unity, Godot, Unreal, custom): design documents,
then building, running and fixing the game.
Set a repo up with `skill-kit game sync`, run `init`, then `setup`.

## Flow

```mermaid
flowchart TD
  setup[setup<br/>fits the kit to the engine] --> mcp[setup-mcp<br/>optional]
  setup --> gdd
  mcp --> gdd[gdd]
  gdd --> mechanic[mechanic]
  mechanic --> balance[balance]
  balance --> impl[implement]
  impl --> run[run]
  run --> broken{does it work?}
  broken -- "compile errors" --> fix[fix]
  broken -- "wrong at runtime" --> logs[logs]
  fix --> run
  logs --> impl
  broken -- "yes, milestone done" --> pm[post-mortem]
```

## Where the files go

| What | Where |
|---|---|
| Game design document | `docs/design/gdd.md` |
| Mechanics | `docs/design/mechanics/<slug>.md` |
| Balance | `docs/design/balance/<slug>.md` |
| Post-mortems | `docs/design/post-mortems/` |

## 1. Setup

Run `setup` once per repo. Every other skill uses the engine facts it records.

| Skill | What it does |
|---|---|
| [setup](skills/setup/README.md) | Records the engine's source folders, logs, error formats, and build and run commands |
| [setup-mcp](skills/setup-mcp/README.md) | Connects an engine-control server, so the kit drives the live engine instead of reading its logs |

## 2. Design

| Skill | What it does |
|---|---|
| [gdd](skills/gdd/README.md) | Creates or edits the overview of what the game is and how it works |
| [mechanic](skills/mechanic/README.md) | Designs one mechanic precisely enough to implement and balance |
| [balance](skills/balance/README.md) | Designs a system's tunable numbers, curves and the reasoning behind them |

## 3. Build, run and fix

| Skill | What it does |
|---|---|
| [run](skills/run/README.md) | Builds and runs the game, so a change can be seen working |
| [fix](skills/fix/README.md) | Fixes the compile errors and warnings in the project's own code |
| [logs](skills/logs/README.md) | Reads the runtime log: output, exceptions, stack traces |

## 4. Looking back

| Skill | What it does |
|---|---|
| [post-mortem](skills/post-mortem/README.md) | What was planned, what happened, and the lessons for a milestone |

## Settings

For a game with a story, [character](../../shared/skills/character/README.md),
[world](../../shared/skills/world/README.md), [item](../../shared/skills/item/README.md) and
[outline](../../shared/skills/outline/README.md) work here too.
