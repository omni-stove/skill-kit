#!/bin/sh
# Per-project layout file — ONE per project. `.agents/refs/layout.sh` resolves it
# deterministically (load_project <id> sources this), so it is never sourced with a
# project argument: it already IS the project. Copy this to .agents/refs/layouts/<id>.sh
# and point the paths at where THIS project actually keeps its files. Paths may be
# relative to the repo root or absolute — the project need not live in this repo, and
# there is no assumed base like src/ or docs/.
#
# Every function echoes one path and takes at most a name ($1); no project id is passed
# (the loaded file is the project). The function NAMES are the contract skills rely on;
# the paths are yours to set. Keep every name even if a project doesn't use it.

# One place to set THIS project's base, reused below. Inline concrete paths instead if
# a project's directories don't share a common base — the names are what matter.
_base() { echo "src/co"; }   # <- point at THIS project's directory (edit per project)

readme()                { echo "$(_base)/README.md"; }

characters()            { echo "$(_base)/characters"; }
characters_main()       { echo "$(_base)/characters/main/$1.md"; }
characters_supporting() { echo "$(_base)/characters/supporting/$1.md"; }
characters_antagonist() { echo "$(_base)/characters/antagonist/$1.md"; }
characters_archive()    { echo "$(_base)/characters/archive/$1.md"; }

world()                 { echo "$(_base)/world"; }
items()                 { echo "$(_base)/items"; }

story()                 { echo "$(_base)/story"; }
story_plot()            { echo "$(_base)/story/plot"; }
story_plot_file()       { echo "$(_base)/story/plot/$1.md"; }        # $1 = english-title
story_outline()         { echo "$(_base)/story/outline"; }
story_synopsis()        { echo "$(_base)/story/synopsis.txt"; }
story_timeline()        { echo "$(_base)/story/timeline.md"; }
story_memo()            { echo "$(_base)/story/memo/$1.md"; }        # $1 = filename
story_body_file()       { echo "$(_base)/story/$1.md"; }            # $1 = chapter
