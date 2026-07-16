#!/bin/sh
# Doc layout — the single source of truth for where a repo keeps its game-design
# documents. Skills never hardcode paths; they source this file and call a function to
# get a resolved path. To adapt the kit to a repo that lays its docs out differently,
# override this file: drop a real .agents/refs/layout.sh into the repo (sync leaves real
# files untouched) and redefine the functions below. The function NAMES are the
# contract; the paths they return are not.
#
# Usage from a skill:
#   sh -c '. .agents/refs/layout.sh; mechanic_file "double-jump"'
#     -> docs/design/mechanics/double-jump.md
#
# Every function echoes one resolved path relative to the repo root, no trailing slash.
# $1 (when present) is the runtime name/slug the user gave you. If a location a skill
# needs is not defined here, do not guess a path — stop and ask the user to define it in
# their repo's .agents/refs/layout.sh (the `setup` skill does this interactively).

design_root()     { echo "docs/design"; }
gdd_file()        { echo "docs/design/gdd.md"; }             # top-level game design document

mechanics()       { echo "docs/design/mechanics"; }          # the dir
mechanic_file()   { echo "docs/design/mechanics/$1.md"; }    # $1 = mechanic slug

balance()         { echo "docs/design/balance"; }            # the dir
balance_file()    { echo "docs/design/balance/$1.md"; }      # $1 = system slug

levels()          { echo "docs/design/levels"; }             # the dir
level_file()      { echo "docs/design/levels/$1.md"; }       # $1 = level slug
