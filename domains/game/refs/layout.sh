#!/bin/sh
# Doc layout — where a game repo keeps its game-design documents, plus the deterministic
# per-project resolver the shared setting skills use.
#
# Two kinds of location live here:
#
# 1. The game's own design docs (gdd / mechanics / balance / levels). A game repo has one
#    design tree, so these are plain functions off design_root — no project id. Skills
#    source this file and call them directly:
#      sh -c '. .agents/refs/layout.sh; mechanic_file "double-jump"'
#        -> docs/design/mechanics/double-jump.md
#
# 2. The shared setting skills (character / world / item / timeline). Those run in both
#    domains and resolve paths through a PER-PROJECT layout file, exactly as in story:
#      sh -c '. .agents/refs/layout.sh; load_project hero; characters_main "アリス"'
#        -> whatever hero's layout file defines
#
# The function NAMES are the contract; the values are what you change for this repo. To
# adapt a repo that lays its docs out differently, override this file (sync leaves real
# files untouched). If a location a skill needs is not defined here, do not guess — stop
# and ask the user to define it (the `setup` skill does this interactively).

# --- The game's design docs (single tree, no project id) ----------------------
design_root()     { echo "docs/design"; }
gdd_file()        { echo "docs/design/gdd.md"; }             # top-level game design document

mechanics()       { echo "docs/design/mechanics"; }          # the dir
mechanic_file()   { echo "docs/design/mechanics/$1.md"; }    # $1 = mechanic slug

balance()         { echo "docs/design/balance"; }            # the dir
balance_file()    { echo "docs/design/balance/$1.md"; }      # $1 = system slug

levels()          { echo "docs/design/levels"; }             # the dir
level_file()      { echo "docs/design/levels/$1.md"; }       # $1 = level slug

# --- Shared setting skills: deterministic per-project resolver -----------------
# Identical mechanism to story. The shared character / world / item / timeline skills
# pass only a project id; sh maps it to that project's layout file, sources it, and the
# project's structural functions (characters_main & siblings, world, items, readme,
# story_timeline — each taking just a name) come into scope. Per-project files are
# scaffolded from layout-template.sh by `setup` and may point anywhere on disk.
project_layout() { echo ".agents/refs/layouts/$1.sh"; }

load_project() {
	_lf=$(project_layout "$1")
	[ -f "$_lf" ] || { echo "layout: no layout file for project '$1' (looked at $_lf) — run the setup skill to create one" >&2; return 1; }
	. "$_lf"
}
