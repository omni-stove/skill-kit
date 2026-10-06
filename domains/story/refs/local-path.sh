#!/bin/sh
# Sourced by the scripts that take a path from the user:
#   . "$(dirname -- "$0")/../../../refs/local-path.sh"   (from refs/: "$(dirname -- "$0")/local-path.sh")
#   set -- "$(local_path "$1")"
# local_path <path> prints the path with a file:// URL turned into the plain
# path — scheme and host dropped, %XX decoded — and any other path unchanged.
local_path() {
  case "$1" in
    file://*) ;;
    *) printf '%s\n' "$1"; return ;;
  esac
  _r=${1#file://}
  _r=/${_r#*/}
  _p=
  while [ -n "$_r" ]; do
    case "$_r" in
      %[0-9A-Fa-f][0-9A-Fa-f]*)
        _h=${_r#%}
        _h=${_h%"${_h#??}"}
        _p=$_p$(printf "\\$(printf '%03o' "0x$_h")")
        _r=${_r#%??} ;;
      *)
        _p=$_p${_r%"${_r#?}"}
        _r=${_r#?} ;;
    esac
  done
  printf '%s\n' "$_p"
}
