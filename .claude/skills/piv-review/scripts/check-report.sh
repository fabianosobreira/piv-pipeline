#!/usr/bin/env sh
# Checks a review report before it is handed on: the template's header fields are
# filled, its headings are present and in order, no section is left empty, every
# `path:line` it cites exists in the working tree, every finding outside Test facts carries
# its origin, and the verdict agrees with the findings. It reads the report and the
# files it cites; it changes nothing. The report's path is the first argument; the
# repository root is the current directory, where the cited paths are relative to.
#
# Usage: check-report.sh [report]
# Needs: a POSIX shell, awk, grep, sed, tr, wc, tail, sort and mktemp.
# Exit: 0 = every check passed, 1 = at least one check failed (one line per problem on
# stderr), 2 = usage or setup error.

set -eu

if [ "$#" -ne 1 ]; then
  echo "check-report: missing [report]. Usage: check-report.sh [report]" >&2
  exit 2
fi

report=$1

if [ ! -f "$report" ]; then
  echo "check-report: '$report' is not a file. Pass the review report's path." >&2
  exit 2
fi

problems=$(mktemp)
trap 'rm -f "$problems" "$problems.sections"' EXIT

fail() {
  echo "check-report: $1" >&2
  echo x >> "$problems"
}

# Header fields: each must carry a value after the colon, and not the template's
# [placeholder].
for field in Intent-slug Issue Task Branch Round Base "Diff hash" Verdict; do
  if ! grep -Eq "^- \*\*$field\*\*: [^[:space:]]" "$report"; then
    fail "header field '$field' is missing or empty"
    if [ "$field" = "Diff hash" ] && grep -Eq '^- \*\*Diff\*\*:' "$report"; then
      fail "the header carries the old '**Diff**' field; rename it to '**Diff hash**'"
    fi
  elif grep -Eq "^- \*\*$field\*\*: [[]" "$report"; then
    fail "header field '$field' still holds the template's [placeholder]; replace it with the value"
  fi
done

verdict=$(sed -n 's/^- \*\*Verdict\*\*: //p' "$report" | head -n 1 | tr -d '\r')
case "$verdict" in
  "PASS" | "CHANGES REQUESTED") ;;
  *) fail "Verdict is '$verdict'; it must be PASS or CHANGES REQUESTED" ;;
esac

# Headings: each must be present, and together they must follow the template's order.
headings="## Scope|## Findings|### Test facts|### Critical|### High|### Medium|### Low|## Dropped by prior ruling|## Checks run"
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

# Section content: every section but "## Findings" (which only holds the severity
# headings) carries text. An empty severity section must read "No findings.", an
# empty "Dropped by prior ruling" must read "None.", and a severity section that
# reads "No findings." holds nothing else.
awk '
  { sub(/\r$/, "") }
  /^##+ / { sec = $0; order[++n] = sec; next }
  sec == "" || sec == "## Findings" { next }
  $0 ~ /[^[:space:]]/ { filled[sec] = 1 }
  $0 == "No findings." { nofind[sec] = 1; next }
  $0 ~ /[^[:space:]]/ { other[sec] = 1 }
  END {
    for (i = 1; i <= n; i++) {
      s = order[i]
      if (s == "## Findings") continue
      if (!(s in filled)) {
        if (s ~ /^### /) print "\"" s "\" is empty; write \"No findings.\" when it holds none"
        else if (s == "## Dropped by prior ruling") print "\"" s "\" is empty; write \"None.\" when nothing was dropped"
        else print "\"" s "\" is empty"
      } else if ((s in nofind) && (s in other)) {
        print "\"" s "\" reads \"No findings.\" but also holds other lines; keep one or the other"
      }
    }
  }
' "$report" > "$problems.sections"
while IFS= read -r line; do
  fail "$line"
done < "$problems.sections"
rm -f "$problems.sections"

# Origins and verdict: a finding is a top-level "- ", "* " or "+ " line of a findings section. Outside
# Test facts, it ends on " · [class] · [origin]"; a Test facts finding carries no origin.
# PASS holds only when Test facts is empty and no finding sits under Critical, High or Medium.
findings=$(awk '
  { sub(/\r$/, ""); sub(/[[:space:]]+$/, "") }
  /^### (Test facts|Critical|High|Medium|Low)$/ { sec = ($2 == "Test") ? "Test-facts" : $2; next }
  /^##/ { sec = "" }
  sec == "" || $0 !~ /^[-*+] / { next }
  sec == "Test-facts" && / · (introduced|aggravated)$/ { print "tagged " $0; print "holds Test-facts"; next }
  sec == "Test-facts" { print "holds Test-facts"; next }
  $0 !~ / · (logic|security|performance|quality|standards|coverage) · (introduced|aggravated)$/ { print "origin " sec ": " $0; next }
  sec != "Low" && ($NF == "introduced" || $NF == "aggravated") { print "holds " sec }
' "$report")
holding=$(printf '%s\n' "$findings" | sed -n 's/^holds //p' | sort -u | tr '\n' ' ' | sed 's/ $//')
printf '%s\n' "$findings" | sed -n 's/^origin //p' | while IFS= read -r line; do
  fail "finding in $line; end its line with ' · [class] · [origin]', the class one of logic, security, performance, quality, standards or coverage, the origin introduced or aggravated"
done
printf '%s\n' "$findings" | sed -n 's/^tagged //p' | while IFS= read -r line; do
  fail "Test facts finding carries an origin: $line; drop it, a test-fact finding has none"
done
if [ "$verdict" = "PASS" ] && [ -n "$holding" ]; then
  case " $holding " in
    *" Test-facts "*) fail "Verdict is PASS but Test facts holds a finding" ;;
  esac
  other=$(printf '%s\n' "$holding" | tr ' ' '\n' | grep -vx 'Test-facts' | tr '\n' ' ' | sed 's/ $//' || true)
  if [ -n "$other" ]; then
    fail "Verdict is PASS but $other holds an introduced or aggravated finding of severity Critical, High or Medium"
  fi
fi
if [ "$verdict" = "CHANGES REQUESTED" ] && [ -z "$holding" ]; then
  fail "Verdict is CHANGES REQUESTED but no finding is a test fact, or introduced or aggravated of severity Critical, High or Medium"
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
