#!/bin/sh
# Engine contract — the single source of truth for engine-specific facts a skill needs:
# where this project's own source lives, where the engine writes its log, how to build
# and run, and the grep patterns that pull compile errors / runtime exceptions / call
# sites out of that log. Skills never hardcode any of this; they source this file and
# call a function to get the resolved value. To adapt the kit to a different engine
# (Godot, Unreal, a custom engine) or a repo laid out differently, override this file:
# drop a real .agents/refs/engine.sh into the repo (sync leaves real files untouched)
# and redefine the functions below. The function NAMES are the contract; the values
# they echo are not.
#
# The defaults below target Unity (C#, macOS Editor.log) as the reference engine. The
# `setup` skill detects the actual engine and rewrites these for the repo at hand.
#
# Usage from a skill:
#   sh -c '. .agents/refs/engine.sh; runtime_log'
#     -> /Users/you/Library/Logs/Unity/Editor.log
#   PAT=$(sh -c '. .agents/refs/engine.sh; compile_error_pattern')
#   grep -oE "$PAT" "$(sh -c '. .agents/refs/engine.sh; runtime_log')" | tail -200 | sort -u
#
# Each function echoes exactly one value (a path, a command, or a grep pattern) and
# nothing else. If a value a skill needs is not defined here, do not guess. Stop and ask
# the user to define it in their repo's .agents/refs/engine.sh (the `setup` skill does
# this interactively). There is no hidden default beyond what is written here.

# --- Identity ---------------------------------------------------------------
engine_name()        { echo "Unity"; }

# --- Source layout ----------------------------------------------------------
# The directory holding THIS project's own code — used to scope greps and to know what
# is safe to edit. Everything outside it (engine, plugins, packages) is off-limits.
source_root()        { echo "Assets"; }
# Space-separated path fragments to treat as third-party / off-limits, matched anywhere
# in a path. Skills exclude these from edits and treat their log frames as noise.
third_party()        { echo "Packages/ Plugins/ Library/ ThirdParty/"; }

# --- Logs -------------------------------------------------------------------
# Live engine/editor log the running game writes to (Debug.Log, warnings, exceptions).
runtime_log()        { echo "$HOME/Library/Logs/Unity/Editor.log"; }
# Previous session's log, if the engine rotates one.
runtime_log_prev()   { echo "$HOME/Library/Logs/Unity/Editor-prev.log"; }
# Where compile errors land. For Unity this is the same Editor.log; other engines may
# write build output elsewhere.
build_log()          { runtime_log; }

# --- Grep patterns (grep -E / -oE compatible) -------------------------------
# Match a compile error/warning line and enough context to act on it. Unity emits
# `Assets/Foo.cs(12,3): error CS1002: ; expected`.
compile_error_pattern() { echo "(error|warning) [A-Z]+[0-9]+: .*"; }
# Match runtime exception / error lines in the log.
runtime_error_pattern() { echo "Exception:|Error:|NullReference|IndexOutOfRange|ArgumentException|MissingReference"; }
# Extract a "file:line" call site from a log stack frame. Unity writes
# `... (at Assets/Foo/Bar.cs:42)`.
call_site_pattern()     { echo "at $(source_root)/[^)]+\)"; }

# --- Build / run ------------------------------------------------------------
# How to build the project from the shell, or a human instruction if it can't be
# scripted. Unity compiles inside the Editor, so there is no shell build by default.
build_cmd()          { echo "# Unity recompiles in the Editor — no shell build. Switch to the Editor window to trigger a compile."; }
# How to run the game, or a human instruction. Unity runs via the Editor's Play button.
run_cmd()            { echo "# Press Play in the Unity Editor to run. This tool cannot enter Play Mode."; }
# How to launch the engine HEADLESS / batch mode from the shell — run tests, execute a
# build/setup method, or drive the game with no GUI. This is the agent's preferred way to
# make the project *do* something without an editor GUI (see refs/scriptability-rules.md).
# A human instruction (leading `#`) if the engine truly can't run headless; `setup` fills
# in the real binary path and entry method for this repo.
headless_cmd()       { echo "# Unity headless (setup fills in <Unity> binary path + method): <Unity> -batchmode -nographics -projectPath \"\$(pwd)\" -logFile - -quit  [-runTests | -executeMethod <Class.Method>]"; }
# One-line hint on how the user makes changes take effect after an edit.
recompile_hint()     { echo "Switch back to the Unity Editor window; it recompiles on focus."; }

# --- Engine-control MCP (optional) ------------------------------------------
# If this repo has an MCP server that can DRIVE the engine — trigger a recompile, enter
# Play Mode, run tests, read the live console through a structured API — name its tool
# prefix here. Skills that can do more with a live engine (fix/logs/run) check this: when
# it is non-empty they prefer the MCP tools whose names start with this prefix; when it is
# empty they fall back to log-scraping and human build/run instructions. The `setup-mcp`
# skill configures the server in this repo's .mcp.json and fills this in. Empty by default
# — the kit bundles no MCP server, so nothing here breaks a repo that has none.
control_mcp()        { echo ""; }   # e.g. "mcp__unity__" when a Unity Editor MCP bridge is wired up
