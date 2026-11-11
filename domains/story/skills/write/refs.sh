#!/bin/sh
cat .agents/refs/japanese-web-novel-sentence-guard.md
cat .agents/refs/japanese-web-novel-narration-guard.md
[ ! -f author-rules.md ] || { cat .agents/refs/author-override.md; cat author-rules.md; }
