#!/bin/sh
# Print the files the 梗概 draws on — README.md, the character files, and the existing
# story/synopsis.txt when there is one — then how to draft it.
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
echo "== read =="
[ -f README.md ] && echo README.md
find characters -type f -name '*.md' 2>/dev/null | sort
if [ -f story/synopsis.txt ]; then
  echo story/synopsis.txt
  prompt exists
fi
prompt draft
