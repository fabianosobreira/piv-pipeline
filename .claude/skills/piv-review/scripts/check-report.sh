#!/usr/bin/env sh
# Checks a review report before it is handed on: the template's header fields and
# headings are present, every `path:line` it cites exists in the working tree, and
# the verdict agrees with the findings. It reads the report and the files it cites;
# it changes nothing. The report's path is the first argument; the repository root
# is the current directory, where the cited paths are relative to.
#
# Usage: check-report.sh <report>
# Needs: a POSIX shell, awk and wc.
# Exit: 0 = every check passed, 1 = at least one check failed (one line per problem on
# stderr), 2 = usage or setup error.

set -eu

if [ "$#" -ne 1 ]; then
  echo "check-report: missing <report>. Usage: check-report.sh <report>" >&2
  exit 2
fi

report=$1

if [ ! -f "$report" ]; then
  echo "check-report: '$report' is not a file. Pass the review report's path." >&2
  exit 2
fi

problems=$(mktemp)
trap 'rm -f "$problems"' EXIT

fail() {
  echo "check-report: $1" >&2
  echo x >> "$problems"
}

# Header fields: each must carry a value after the colon.
for field in Intent-slug Ticket Branch Round Base Diff Verdict; do
  if ! grep -Eq "^- \*\*$field\*\*: [^[:space:]]" "$report"; then
    fail "header field '$field' is missing or empty"
  fi
done

verdict=$(sed -n 's/^- \*\*Verdict\*\*: //p' "$report" | head -n 1 | tr -d '\r')
case "$verdict" in
  "PASS" | "CHANGES REQUESTED") ;;
  *) fail "Verdict is '$verdict'; it must be PASS or CHANGES REQUESTED" ;;
esac

# Headings: each must be present, and together they must follow the template's order.
headings="## Scope|## Findings|### Blocking|### Critical|### High|### Medium|### Low|## Dropped by prior ruling|## Checks run"
absent=""
old_ifs=$IFS
IFS='|'
for h in $headings; do
  if ! tr -d '\r' < "$report" | grep -Fxq -- "$h"; then absent="$absent${absent:+, }$h"; fi
done
IFS=$old_ifs
if [ -n "$absent" ]; then
  fail "heading(s) missing: $absent"
else
  # Every heading exists; walk the report once and confirm they appear in the template's order.
  in_order=$(awk -v want="$headings" '
    BEGIN { n = split(want, w, "|"); i = 1 }
    { sub(/\r$/, "") }
    i <= n && $0 == w[i] { i++ }
    END { print (i > n) ? "yes" : "no" }
  ' "$report")
  if [ "$in_order" != "yes" ]; then fail "headings are present but out of the template's order"; fi
fi

# Verdict against findings: PASS holds only when Blocking, Critical and High are empty.
# A severity section is empty when its only content is "No findings.".
heavy=$(awk '
  { sub(/\r$/, "") }
  /^### (Blocking|Critical|High)$/ { sec = $2; next }
  /^##/ { sec = "" }
  sec != "" && $0 != "" && $0 != "No findings." { heavy[sec] = 1 }
  END { for (s in heavy) printf "%s ", s }
' "$report")
if [ "$verdict" = "PASS" ] && [ -n "$heavy" ]; then
  fail "Verdict is PASS but $heavy section(s) hold findings"
fi
if [ "$verdict" = "CHANGES REQUESTED" ] && [ -z "$heavy" ]; then
  fail "Verdict is CHANGES REQUESTED but Blocking, Critical and High hold no findings"
fi

# Citations: a backticked `path:line` or `path:start-end`. The path must exist and the
# line must fall inside the file. A deleted file has no line to cite, so cite its
# change by the surviving test or caller instead.
cites=$(grep -Eo '`[A-Za-z0-9_./-]+\.[A-Za-z0-9]+:[0-9]+(-[0-9]+)?`' "$report" | tr -d '`' | sort -u || true)
for cite in $cites; do
  path=${cite%%:*}
  range=${cite#*:}
  first=${range%%-*}
  last=${range##*-}
  if [ ! -f "$path" ]; then
    fail "$cite: '$path' does not exist from $(pwd)"
    continue
  fi
  total=$(wc -l < "$path" | tr -d ' ')
  # wc -l counts newlines; a last line with no newline still exists
  if [ -n "$(tail -c 1 "$path")" ]; then total=$((total + 1)); fi
  if [ "$first" -lt 1 ] || [ "$last" -lt "$first" ] || [ "$last" -gt "$total" ]; then
    fail "$cite: $path has $total lines"
  fi
done

if [ -s "$problems" ]; then
  exit 1
fi
echo "check-report: ok"
