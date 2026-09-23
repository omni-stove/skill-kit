#!/bin/sh
# Usage: format.sh <story file>
# Fixes in place, noting the count on stderr: indentation — one full-width space
# opens each narration line; lines opening with 「, 『, （, 【, 〖, 〔, ［, 〈 or 《 and
# the ◇◇◇ separator get none; …… becomes ――; 。」 loses its period; ！／？ gets a
# full-width space after it unless 」, 』, ）, ― or the line end follows. Then lists
# the lines that break the other mechanical rules of japanese-web-novel-format.md,
# grouped by rule as `<line number>:<line>`; prints nothing when there are none.
# A leading `Source:` / `POV:` header and one blank line after it are skipped.
# Same-speaker dialogue runs and the use of 『』 stay with the reader.
# Patterns use alternation, never a multibyte bracket, so any locale works.
set -eu
[ $# -eq 1 ] || { echo "usage: format.sh <story file>" >&2; exit 2; }
f=$1
[ -f "$f" ] || { echo "format: no such file: $f" >&2; exit 1; }
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
awk '
BEGIN { hdr = 1 }
hdr && /^(Source|POV): / { print; next }
{ hdr = 0; sub(/^(　| |\t)+/, "") }
$0 != "" && $0 !~ /^(「|『|（|【|〖|〔|［|〈|《|◇)/ { $0 = "　" $0 }
{
  gsub(/(…)+/, "――")
  gsub(/。」/, "」")
  gsub(/(！|？)+/, "&\001")
  gsub(/\001 +/, "\001")
  gsub(/\001(　|」|』|）|―)/, "\002&")
  gsub(/\002\001/, "")
  sub(/\001$/, "")
  gsub(/\001/, "　")
}
{ print }' "$f" > "$tmp"
if ! cmp -s "$tmp" "$f"; then
  n=$(diff "$f" "$tmp" | grep -c '^>' || true)
  cat "$tmp" > "$f"
  echo "format: fixed $n line(s) of $f" >&2
fi
awk '
function hit(rule, n) { hits[rule] = hits[rule] n ":" line[n] "\n" }
{ line[NR] = $0 }
END {
  first = 1
  while (first <= NR && line[first] ~ /^(Source|POV): /) first++
  if (first > 1 && first <= NR && line[first] == "") first++

  for (n = first; n <= NR; n++) {
    s = line[n]
    if (s == "") {
      if (line[n - 1] != "◇◇◇" && line[n + 1] != "◇◇◇") hit("blank", n)
      continue
    }
    if (s ~ /◇/) {
      if (s != "◇◇◇" || n == first || n == NR || line[n - 1] != "" || line[n + 1] != "") hit("separator", n)
      continue
    }
    if (s ~ /^(　)?(#+ |[-*+] |> |```)/ || s ~ /\*\*[^*]+\*\*/) hit("markdown", n)
    if (s ~ /^「/ && s !~ /」$/) hit("dialogue", n)
    t = s; gsub(/――/, "", t)
    if (t ~ /―/) hit("dash", n)
    if (s ~ /[0-9]|０|１|２|３|４|５|６|７|８|９/) hit("numeral", n)
    t = s; gsub(/《/, "\001", t); gsub(/》/, "\002", t)
    gsub(/\|[^|\001\002]+\001[^\001\002]+\002/, "", t)
    if (t ~ /[|\001\002]|｜/) hit("ruby", n)
  }

  label["markdown"] = "markdown formatting"
  label["blank"] = "blank line away from ◇◇◇"
  label["separator"] = "◇◇◇ not alone on its line between two blank lines"
  label["dialogue"] = "dialogue sharing its line"
  label["dash"] = "― outside a ―― pair"
  label["numeral"] = "arabic numeral"
  label["ruby"] = "ruby outside |単語《ルビ》"
  split("markdown blank separator dialogue dash numeral ruby", order, " ")
  for (i = 1; i in order; i++)
    if (order[i] in hits) printf "%s%s:\n%s", (shown++ ? "\n" : ""), label[order[i]], hits[order[i]]
}' "$f"
