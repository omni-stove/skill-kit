#!/bin/sh
# Usage: format.sh <story file>
# Fixes in place, noting the count on stderr: indentation — one full-width space
# opens each narration line; lines opening with 「, 『, （, 【, 〖, 〔, ［, 〈 or 《 and
# the ◇◇◇ separator get none; …… becomes ――; — and ─ become ―; a ― run of odd
# length gains one ―; ｜ becomes |; **bold** loses its asterisks; 。」 loses its
# period; ！／？ gets a full-width space after it unless 」, 』, ）, ― or the line
# end follows; a line of ◇ alone becomes ◇◇◇ with a blank line before and after
# it. Then lists the lines that break the other mechanical rules of
# japanese-web-novel-format.md, grouped by rule as `<line number>:<line>`; prints
# nothing when there are none.
# A leading header of `Key: value` lines (Source, POV, Memo, ...) and one blank
# line after it are skipped.
# Same-speaker dialogue runs and the use of 『』 stay with the reader.
# Patterns use alternation, never a multibyte bracket, so any locale works.
set -eu
[ $# -eq 1 ] || { echo "usage: format.sh <story file>" >&2; exit 2; }
. "$(dirname -- "$0")/local-path.sh"
set -- "$(local_path "$1")"
f=$1
[ -f "$f" ] || { echo "format: no such file: $f" >&2; exit 1; }
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
awk '
BEGIN { hdr = 1 }
hdr && /^[A-Z][A-Za-z]*: / { line[++m] = $0; next }
hdr && m && $0 == "" { line[++m] = $0; hdr = 0; first = m + 1; next }
{ if (hdr) first = m + 1; hdr = 0; sub(/^(　| |\t)+/, "") }
/^(◇|　| |\t)+$/ { $0 = "◇◇◇" }
$0 != "" && !/^(「|『|（|【|〖|〔|［|〈|《|◇)/ { $0 = "　" $0 }
{
  gsub(/(…)+/, "――")
  gsub(/—|─/, "―")
  gsub(/――/, "\003")
  gsub(/―/, "\003")
  gsub(/\003/, "――")
  gsub(/｜/, "|")
  while (match($0, /\*\*[^*]+\*\*/))
    $0 = substr($0, 1, RSTART - 1) substr($0, RSTART + 2, RLENGTH - 4) substr($0, RSTART + RLENGTH)
  gsub(/。」/, "」")
  gsub(/(！|？)+/, "&\001")
  gsub(/\001 +/, "\001")
  gsub(/\001(　|」|』|）|―)/, "\002&")
  gsub(/\002\001/, "")
  sub(/\001$/, "")
  gsub(/\001/, "　")
  line[++m] = $0
}
END {
  if (!first) first = m + 1
  for (n = 1; n <= m; n++) {
    sep = line[n] ~ /^◇◇◇$/
    if (sep && n > first && line[n - 1] != "") print ""
    print line[n]
    if (sep && n < m && line[n + 1] != "") print ""
  }
}' "$f" > "$tmp"
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
  while (first <= NR && line[first] ~ /^[A-Z][A-Za-z]*: /) first++
  if (first > 1 && first <= NR && line[first] == "") first++

  for (n = first; n <= NR; n++) {
    s = line[n]
    if (s == "") {
      if (line[n - 1] !~ /^◇◇◇$/ && line[n + 1] !~ /^◇◇◇$/) hit("blank", n)
      continue
    }
    if (s ~ /◇/) {
      if (s !~ /^◇◇◇$/ || n == first || n == NR || line[n - 1] != "" || line[n + 1] != "") hit("separator", n)
      continue
    }
    if (s ~ /^(　)?(#+ |[-*+] |> |```)/) hit("markdown", n)
    if (s ~ /^「/ && s !~ /」$/) hit("dialogue", n)
    if (s ~ /[0-9]|０|１|２|３|４|５|６|７|８|９/) hit("numeral", n)
    t = s; gsub(/《/, "\001", t); gsub(/》/, "\002", t)
    gsub(/\|[^|\001\002]+\001[^\001\002]+\002/, "", t)
    if (t ~ /[|\001\002]|｜/) hit("ruby", n)
  }

  label["markdown"] = "markdown formatting"
  label["blank"] = "blank line away from ◇◇◇"
  label["separator"] = "◇◇◇ not alone on its line between two blank lines"
  label["dialogue"] = "dialogue sharing its line"
  label["numeral"] = "arabic numeral"
  label["ruby"] = "ruby outside |単語《ルビ》"
  split("markdown blank separator dialogue numeral ruby", order, " ")
  for (i = 1; i in order; i++)
    if (order[i] in hits) printf "%s%s:\n%s", (shown++ ? "\n" : ""), label[order[i]], hits[order[i]]
}' "$f"
