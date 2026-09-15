#!/bin/sh
# $1 = since date, $2 = optional until date -> one line per commit of the period.
git log --date=short --format='%ad %s' --since="${1:?usage: commits.sh <since> [<until>]}" ${2:+--until="$2"}
