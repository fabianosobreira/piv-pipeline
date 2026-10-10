#!/usr/bin/env sh
# Prints the line number of every line in <file> that contains <text>, as `path:line: content`,
# so a finding cites the number the file really has instead of one counted by hand.
# <text> is matched as a fixed string on a single line, not as a pattern.
#
# Usage: locate.sh <file> <text>
# Needs: a POSIX shell and grep.
# Exit: 0 = at least one line matches, 1 = no line matches, 2 = usage or setup error.

set -eu

if [ "$#" -ne 2 ]; then
  echo "locate: expected <file> <text>. Usage: locate.sh <file> <text>" >&2
  exit 2
fi

file=$1
text=$2

if [ ! -f "$file" ]; then
  echo "locate: '$file' is not a file. Pass the path relative to the repository root." >&2
  exit 2
fi

if [ -z "$text" ]; then
  echo "locate: <text> is empty. Pass a piece of the line you want to cite." >&2
  exit 2
fi

# grep -n counts lines the way editors do, whatever the file's line endings. awk cuts the content at 120
# characters (a constant: enough to tell two matches apart, short enough to keep the output readable).
# `|| true` keeps `set -e` from ending the script on grep's exit 1, so the no-match message below is reached.
matches=$(grep -nF -- "$text" "$file" | tr -d '\r' | awk -v f="$file" '{ i = index($0, ":"); print f ":" substr($0, 1, i - 1) ": " substr(substr($0, i + 1), 1, 120) }' || true)

if [ -z "$matches" ]; then
  echo "locate: no line in '$file' contains '$text'. Check the spelling, or search a shorter piece of the line." >&2
  exit 1
fi

echo "$matches"
