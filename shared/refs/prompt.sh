#!/bin/sh
# Sourced by a skill's scripts/*.sh to print what the reader does next from the skill's
# prompts/<name>.txt, kept beside scripts/ so the words live apart from the code:
#   . "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"   (from shared/skills/: four ..)
#   prompt <name> [key=value]...
# Each {key} in the file is replaced by its value; the rest is printed as it stands.
prompt() {
  _t=$(cat "$(dirname -- "$0")/../prompts/$1.txt"; printf x)
  _t=${_t%x}
  shift
  for _kv in "$@"; do
    _k="{${_kv%%=*}}"
    _v=${_kv#*=}
    _o=
    while :; do
      case $_t in
        *"$_k"*) _o=$_o${_t%%"$_k"*}$_v; _t=${_t#*"$_k"} ;;
        *) break ;;
      esac
    done
    _t=$_o$_t
  done
  printf '%s' "$_t"
}
