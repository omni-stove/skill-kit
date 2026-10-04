---
name: run
description: Build and/or run the game so a change can be seen working, using this repo's engine build/run commands. Use when the user asks to run, launch, build, or play-test the game, or to confirm a change works in the actual running game (e.g. "動かして", "ビルドして", "run the game", "play-test this").
---

Run `.agents/skills/run/refs.sh`

# Build / run the game

Launch or build the game, then observe that it works, following the loaded rules.

Run `.agents/skills/run/scripts/commands.sh`

Make the project do something by the highest-preference path available:

1. Engine-control MCP (`ctrl` non-empty) — drive Play Mode / tests / build through its
   tools.
2. Headless / batch mode (`headless`) — run tests or an entry point from the shell; output
   goes to a log you can read. The default for an automated, CI-shaped run without an MCP.
3. `build` / `run` — when neither above covers it, or the engine can't run headless.

Any command beginning with `#` is a human instruction, not runnable — relay it verbatim
and wait for the user.

Build first if a build step applies, then run. For a
scriptable/headless run, let it start, then confirm it's up — the process is alive, a
window/port opened, or the expected startup line appeared. Keep a long-running process in
the background so you can read its log while it runs.

A successful build proves it compiles, not that the change behaves — drive the actual
flow and read what the running game printed before calling it done.
