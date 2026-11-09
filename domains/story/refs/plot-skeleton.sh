#!/bin/sh
# Usage: plot-skeleton.sh <file>...
# Writes the plot file skeleton to each file, replacing what is there and creating its
# directory, then prints plot-format.txt: how to fill it.
set -eu
[ $# -ge 1 ] || { echo "usage: plot-skeleton.sh <file>..." >&2; exit 2; }
for f in "$@"; do
  mkdir -p "$(dirname -- "$f")"
  cat > "$f" <<'SKELETON'

## プロットの意図

## 分量

## 禁止事項

## ハイライト

## セリフ
<!-- 指示があるまでこの項目に追加しない -->

## 参照
SKELETON
done
cat "$(dirname -- "$0")/plot-format.txt"
