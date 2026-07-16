#!/bin/sh
# Per-project layout — ONE per project, sourced by `.agents/refs/layout.sh` (load_project
# <id>). It IS the project, so no project id is passed; each function echoes one path and
# takes at most a name ($1). Copy to .agents/refs/layouts/<id>.sh and set _base to this
# project's root — a dir in this repo, a sibling checkout, or an absolute path. The
# function NAMES are the contract skills rely on; keep them all, the paths are yours.

_base() { echo "."; }   # this project's root — everything below hangs off it (repo root by default)

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
