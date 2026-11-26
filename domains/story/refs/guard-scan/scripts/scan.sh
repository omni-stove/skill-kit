#!/bin/sh
# Usage: scan.sh --scene|--whole|--all <story file>
# Fixes the story file's format through format.sh --guard, then prints, under one lead,
# the checks to run by the loaded rules with the lines that call for them.
# --scene: the checks before each hand-off, the narration lines ending on のだ。 or
# のである。, the lines attributing dialogue with a speech verb (」と彼は言った and the
# like), the narration lines with an intensifier (途方もなく, 完璧な and the like), the
# narration lines with a sentence of three or more commas or of two around short
# phrases, the narration lines naming a feeling (安堵, 自己嫌悪に襲われた and the like),
# the narration lines setting a thing against a denied alternative (ではなく, ではない。,
# というより and the like), the narration lines describing a voice or sound (低い声,
# 声は平らだった and the like), the narration lines with a negative sentence ending
# (ない。, なかった。), the narration lines holding a run of four or more narration
# sentences in a row ending on the same form (だ or である, た, い, or another verb's
# dictionary form), and the lines format.sh finds against the format rules.
# --whole: the checks over the whole file, with findings held for the hand-off, the
# narration lines ending on だった with another in the same or next paragraph, and, when
# more than one, the narration lines ending a look or voice on だった (目だった。,
# 声だった。 and the like).
# --all: both, under the --whole lead.
set -eu
case ${1:-} in --scene|--whole|--all) ;; *) set -- ;; esac
[ $# -eq 2 ] || { echo "usage: scan.sh --scene|--whole|--all <story file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
mode=$1
f=$(local_path "$2")
[ -f "$f" ] || { echo "scan: no such file: $f" >&2; exit 1; }
fmt=$(sh "$(dirname -- "$0")/../../format.sh" --guard "$f")

scene() {
  noda=$(grep -nE '(のだ|のである|のだった|のであった)。' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
  if [ -n "$noda" ]; then
    prompt noda
    printf '%s\n' "$noda"
  fi
  # 」という names a phrase rather than attributing a line.
  tag=$(grep -nE '」と[^。]*(言|続け|答え|告げ|問|返し|呟|叫|囁)' "$f" | grep -vE '」とい(う|った)' || true)
  if [ -n "$tag" ]; then
    prompt tag
    printf '%s\n' "$tag"
  fi
  intensifier=$(grep -nE '途方もな|とてつもな|恐ろしいほど|圧倒的|曇りもな|寸分|一寸の狂い|完璧|完全に|極めて|凄まじ|底知れ|限りな|この上な|あまりに' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
  if [ -n "$intensifier" ]; then
    prompt intensifier
    printf '%s\n' "$intensifier"
  fi
  # Counts bytes under LC_ALL=C, three to each kana, kanji or 、: two commas whose three
  # phrases average 8 chars or fewer count as around short phrases.
  comma=$(LC_ALL=C awk '!/^(「|『)/ {
    n = split($0, sent, "。")
    for (i = 1; i <= n; i++) {
      c = gsub(/、/, "、", sent[i])
      if (c >= 3 || c == 2 && (length(sent[i]) - 6) / 9 <= 8) { print NR ":" $0; next }
    }
  }' "$f")
  if [ -n "$comma" ]; then
    prompt comma
    printf '%s\n' "$comma"
  fi
  feeling=$(grep -nE '安堵|自己嫌悪|昂ぶ|高揚|恥じ|嬉し|悲し|寂し|切な|不安|焦り|苛立|怒り|憤|恐ろしかった|恐怖|絶望|後悔|罪悪感|喜び|愛おし|懐かし|虚し|込み上げ|こみ上げ|に襲われ|胸が(痛|締|詰|熱)' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
  if [ -n "$feeling" ]; then
    prompt feeling
    printf '%s\n' "$feeling"
  fi
  contrast=$(grep -nE 'ではな(く|い。|かった。)|というより|でも.*でもなく|のとは違(う|った)。|わけ(では|でも|じゃ)な' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
  if [ -n "$contrast" ]; then
    prompt contrast
    printf '%s\n' "$contrast"
  fi
  # Blanks words that only look like a described voice or sound before matching.
  sound=$(awk '!/^(「|『)/ {
    s = $0
    gsub(/笑い声|銃声|本音|また(声|音)|みな声/, "", s)
    if (s ~ /(い|な|た)(声|音)|(声|音)は|声の(高さ|低さ|調子)|声が(尖|小さ|大き|遠|低|高|細|太|硬|弱|平|震|かす|掠|上ず|裏返)/) print NR ":" $0
  }' "$f")
  if [ -n "$sound" ]; then
    prompt sound
    printf '%s\n' "$sound"
  fi
  # ではない。 and ではなかった。 are on the contrast list already.
  neg=$(awk '!/^(「|『)/ {
    s = $0
    gsub(/ではな(い|かった)。/, "", s)
    if (s ~ /(ない|なかった)。/) print NR ":" $0
  }' "$f")
  if [ -n "$neg" ]; then
    prompt negative
    printf '%s\n' "$neg"
  fi
  # Dialogue, a separator or a line with no 。 ends a run, since the reader hears the
  # ending change there; a sentence ending on a noun or anything else ends one too.
  ending=$(awk '
  function form(s) {
    if (s ~ /(だ|である)$/) return "da"
    if (s ~ /た$/) return "ta"
    if (s ~ /い$/) return "i"
    if (s ~ /(う|く|ぐ|す|つ|ぬ|ぶ|む|る)$/) return "u"
    return ""
  }
  function flush(j) {
    if (run >= 4) for (j = 1; j <= nl; j++) if (!seen[ln[j]]++) print ln[j] ":" line[ln[j]]
    run = 0; nl = 0
  }
  { line[NR] = $0 }
  /^(「|『)/ || !/。/ { prev = ""; flush(); next }
  {
    k = split($0, x, "。")
    for (i = 1; i < k; i++) {
      fm = form(x[i])
      if (fm == "" || fm != prev) flush()
      prev = fm
      if (fm != "") { run++; if (!nl || ln[nl] != NR) ln[++nl] = NR }
    }
  }
  END { flush() }' "$f")
  if [ -n "$ending" ]; then
    prompt ending
    printf '%s\n' "$ending"
  fi
}

whole() {
  # A paragraph is a non-blank line; よう, そう, はず, みたい and の before だった end on no noun.
  datta=$(awk '
  { line[NR] = $0 }
  $0 != "" { p[++m] = NR; c[m] = 0 }
  $0 != "" && !/^(「|『)/ {
    k = split($0, x, "。")
    for (i = 1; i < k; i++) if (x[i] ~ /だった$/ && x[i] !~ /(よう|そう|はず|みたい|の)だった$/) c[m]++
  }
  END { for (i = 1; i <= m; i++) if (c[i] > 1 || c[i] && (c[i - 1] || c[i + 1])) print p[i] ":" line[p[i]] }' "$f")
  if [ -n "$datta" ]; then
    prompt datta
    printf '%s\n' "$datta"
  fi
  look=$(grep -nE '(声|声色|口調|顔|横顔|表情|目|瞳|眼差し|視線|笑み|姿|背中)だった。' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
  if [ "$(printf '%s' "$look" | grep -c '^')" -gt 1 ]; then
    prompt look
    printf '%s\n' "$look"
  fi
}

prompt lead
[ "$mode" = --scene ] || prompt hold
[ "$mode" = --whole ] || prompt checks
[ "$mode" = --scene ] || prompt checks-local
[ "$mode" = --whole ] || scene
[ "$mode" = --scene ] || whole
if [ "$mode" != --whole ] && [ -n "$fmt" ]; then
  prompt format
  printf '%s\n' "$fmt"
fi
