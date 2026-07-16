#!/bin/sh
# Per-project layout for the shared setting skills (character / world / item / timeline) —
# ONE per project, sourced by `.agents/refs/layout.sh` (load_project <id>). It IS the
# project, so no project id is passed; each function echoes one path and takes at most a
# name ($1). Copy to .agents/refs/layouts/<id>.sh and set _base to this project's root — a
# dir in this repo, a sibling checkout, or an absolute path. The function NAMES are the
# contract the shared skills rely on; keep them all, the paths are yours.

_base() { echo "."; }   # this project's root — everything below hangs off it (repo root by default)

readme()                { echo "$(_base)/README.md"; }

characters()            { echo "$(_base)/characters"; }
characters_main()       { echo "$(_base)/characters/main/$1.md"; }
characters_supporting() { echo "$(_base)/characters/supporting/$1.md"; }
characters_antagonist() { echo "$(_base)/characters/antagonist/$1.md"; }
characters_archive()    { echo "$(_base)/characters/archive/$1.md"; }

world()                 { echo "$(_base)/world"; }
items()                 { echo "$(_base)/items"; }

story_timeline()        { echo "$(_base)/timeline.md"; }
