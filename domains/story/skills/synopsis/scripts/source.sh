#!/bin/sh
# Print the files the 梗概 draws on — README.md, the character files, and the existing
# story/synopsis.txt when there is one — then how to draft it.
echo "== read =="
[ -f README.md ] && echo README.md
find characters -type f -name '*.md' 2>/dev/null | sort
if [ -f story/synopsis.txt ]; then
  echo story/synopsis.txt
  echo "story/synopsis.txt exists: revise it instead of drafting from scratch."
fi
cat <<'NEXT'
The story itself is the one already read in this conversation; read the files above (the
key character files among them).

Align on direction with a single AskUserQuestion call: length (400字以内 / 800字程度 /
1200字以上 / お任せ), mandatory elements, elements to omit or downplay, target contest or
audience. With contest rules in this conversation, draft to their evaluation criteria.

Draft the 梗概: tagline or genre → setup → development → ending, revealing the ending,
with events inside each part ordered freely rather than chronologically; state the
protagonist, their goal, and the central conflict early; connect events through character
decisions; keep one through-line with the key turning points and cut episodes that don't
serve it; let the theme come through the events, not a stated moral.

Present the draft to the author and revise on feedback. Then run
.agents/skills/synopsis/scripts/save.sh with the 梗概本文 only on stdin.
NEXT
