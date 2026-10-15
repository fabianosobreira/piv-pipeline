#!/bin/sh
# lint_spec.sh - check structure and traceability of a spec file.
# Usage: sh scripts/lint_spec.sh [spec.md]
# Exit codes: 0 = no findings, 1 = findings, 2 = usage or I/O error.
# Fenced code blocks are ignored. The vague-term check is a heuristic:
# a line in sections 3-5 that contains a listed term and no number is flagged.
# IDs: FR (section 3), NFR (4), AC (5), C (6), D (7), T (8). Every task cites
# its FR, NFR, C and D in the head; every NFR, C and D must be cited by a task.

if [ "$#" -ne 1 ]; then
  echo "usage: lint_spec.sh [spec.md]" >&2
  exit 2
fi
if [ ! -r "$1" ]; then
  echo "error: cannot read '$1'" >&2
  exit 2
fi

LC_ALL=C awk '
function err(msg) { print "FAIL line " NR ": " msg; fails++ }
function fail(msg) { print "FAIL: " msg; fails++ }
function trim(s) { gsub(/^[ \t`]+|[ \t`]+$/, "", s); return s }

# Fill arr with every non-overlapping match of pat in s; return the count.
function collect(s, pat, arr,    n) {
  split("", arr)
  n = 0
  while (match(s, pat)) {
    arr[++n] = substr(s, RSTART, RLENGTH)
    s = substr(s, RSTART + RLENGTH)
  }
  return n
}

# Text between the first "(" and the first "):" of a list item.
function head(s,    a, b) {
  a = index(s, "(")
  b = index(s, "):")
  if (a == 0 || b == 0 || b < a) return ""
  return substr(s, a + 1, b - a - 1)
}

# Prefix of an ID: "NFR-01" -> "NFR".
function prefix(id) { sub(/-[0-9]+$/, "", id); return id }

# Record a cited Q<n> with the first line that cites it.
function cite(q) { if (!(q in cited)) cited[q] = NR }

# Register an ID defined on this line; report a duplicate.
function define(id) {
  if (id in defd) { err("duplicate " id); return }
  defd[id] = NR
  deflist[++ndef] = id
}

BEGIN {
  sec = 0
  split("", refs); split("", qs)
  nv = split("fast quickly easy simple intuitive user-friendly adequate appropriate reasonable robust scalable efficient flexible seamless rápido rapidamente fácil simples intuitivo amigável adequado adequada apropriado razoável robusto escalável eficiente flexível", vague, " ")
  fname = FILENAME; sub(/.*[\/\\]/, "", fname)
}

/^```/ { fence = !fence; next }
fence { next }

/^## Appendix/ { sec = 99; seen[99] = 1; next }
/^## [0-9]+\./ { sec = $2 + 0; seen[sec] = 1; next }
/^## / { sec = 0; next }

/^Status:/ {
  status_seen = 1
  if ($0 !~ /^Status: (draft|ready)[ ]*$/) err("Status must be exactly \"Status: draft\" or \"Status: ready\"")
  next
}

/\[PENDING\]/ { err("unresolved [PENDING] marker") }
/\[DEFERRED\]/ { if (sec != 10) err("[DEFERRED] is only allowed in section 10") }

sec == 0 && /^Intent-slug:/ {
  slug_seen = 1
  if ($0 !~ /\[PENDING\]/) {
    if ($0 !~ /^Intent-slug: [a-z0-9]+(-[a-z0-9]+)*[ ]*$/) err("Intent-slug must be a kebab-case slug in lowercase ASCII")
    else if (fname ~ /\.spec\.md$/) {
      slug = $2; want = fname; sub(/\.spec\.md$/, "", want)
      if (slug != want) err("Intent-slug \"" slug "\" does not match the file name \"" fname "\"")
    }
  }
}
sec == 0 && /^Language:/ {
  lang_seen = 1
  if ($0 !~ /\[PENDING\]/ && $0 !~ /^Language: [A-Za-z][A-Za-z][A-Za-z]?(-[A-Za-z0-9]+)*[ ]*$/) err("Language must be a BCP 47 tag, such as pt-BR")
}

# Collect every Q<n> cited through "Source:" outside the appendix.
sec != 99 && match($0, /Source: Q[0-9]+(, *Q[0-9]+)*/) {
  n = collect(substr($0, RSTART, RLENGTH), "Q[0-9]+", qs)
  for (i = 1; i <= n; i++) cite(qs[i])
}

# Every statement must be a bullet with a source (sections 1-8 and 10).
sec >= 1 && sec <= 10 && sec != 9 && /^[^-|#> \t[<]/ {
  err("text outside a list item has no \"Source: Q<n>\"; write it as a \"- \" bullet")
}
sec >= 1 && sec <= 10 && sec != 9 && /^- / && $0 !~ /Source: Q[0-9]+/ {
  err("list item without \"Source: Q<n>\"")
}

sec == 3 && /^- FR-[0-9]+/ {
  match($0, /^- FR-[0-9]+/); id = substr($0, 3, RLENGTH - 2)
  define(id)
  if ($0 !~ /SHALL/) err(id " must use EARS form: WHEN ... THE SYSTEM SHALL ...")
}

# Sections 4, 6 and 7 number their items so that a task can cite them.
(sec == 4 || sec == 6 || sec == 7) && /^- / && $0 !~ /^- None\./ {
  want = (sec == 4) ? "NFR" : (sec == 6) ? "C" : "D"
  if (match($0, "^- " want "-[0-9]+")) {
    id = substr($0, 3, RLENGTH - 2)
    define(id)
  } else err("item in section " sec " needs a " want "-xx ID")
}

sec == 5 && /^- AC-[0-9]+/ {
  match($0, /^- AC-[0-9]+/); id = substr($0, 3, RLENGTH - 2)
  if (id in ac) err("duplicate " id)
  ac[id] = NR; aclist[++nac] = id
  n = collect(head($0), "[A-Z]+-[0-9]+", refs)
  nfrref = 0
  for (i = 1; i <= n; i++) {
    if (prefix(refs[i]) != "FR") continue
    nfrref++; frcov[refs[i]] = 1
    chk_ref[++nchk] = refs[i]; chk_line[nchk] = NR; chk_owner[nchk] = id
  }
  if (nfrref == 0) err(id " does not reference any FR-xx")
  low = tolower($0)
  if (low !~ /given/ || low !~ /when/ || low !~ /then/) err(id " must use Given/When/Then")
}

sec == 8 && /^- T-[0-9]+/ {
  match($0, /^- T-[0-9]+/); id = substr($0, 3, RLENGTH - 2)
  define(id)
  n = collect(head($0), "[A-Z]+-[0-9]+", refs)
  nfrref = 0
  for (i = 1; i <= n; i++) {
    p = prefix(refs[i])
    if (p != "FR" && p != "NFR" && p != "C" && p != "D") continue
    if (p == "FR") nfrref++
    trcov[refs[i]] = 1
    chk_ref[++nchk] = refs[i]; chk_line[nchk] = NR; chk_owner[nchk] = id
  }
  if (nfrref == 0) err(id " does not reference any FR-xx")
  if (match($0, /Depends on:[^|]*/)) {
    n = collect(substr($0, RSTART, RLENGTH), "T-[0-9]+", refs)
    for (i = 1; i <= n; i++) { chk_ref[++nchk] = refs[i]; chk_line[nchk] = NR; chk_owner[nchk] = id }
  }
  if ($0 !~ /DoD:/) err(id " is missing \"DoD:\"")
}

sec == 9 && /^\|/ {
  split($0, c, "|")
  k = trim(c[2])
  if (k ~ /^AC-[0-9]+$/) {
    row9[k] = NR
    if (trim(c[3]) == "") err(k " has an empty command")
    if (trim(c[4]) == "") err(k " has an empty pass criterion")
    org = trim(c[5])
    if (org == "") err(k " has an empty origin (Q<n> or path:line); check the column count, \"|\" is not allowed inside cells")
    n = collect(org, "Q[0-9]+", qs)
    for (i = 1; i <= n; i++) cite(qs[i])
  }
}

sec == 99 && /^\|/ {
  split($0, c, "|")
  k = trim(c[2])
  if (k ~ /^Q[0-9]+$/) logged[k] = NR
}

sec >= 3 && sec <= 5 && /^(- |\|)/ {
  low = tolower($0)
  gsub(/(nfr|fr|ac|t)-[0-9]+/, "", low)
  gsub(/source: q[0-9]+(, *q[0-9]+)*/, "", low)
  if (low !~ /[0-9]/) {
    for (i = 1; i <= nv; i++) {
      if (low ~ ("(^|[^a-z])" vague[i] "([^a-z]|$)")) {
        err("vague term \"" vague[i] "\" without a measurable value")
        break
      }
    }
  }
}

END {
  for (n = 1; n <= 10; n++) if (!(n in seen)) fail("missing heading \"## " n ". ...\"")
  if (!(99 in seen)) fail("missing heading \"## Appendix: Decision log\"")
  if (!status_seen) fail("missing \"Status:\" line")
  if (!slug_seen) fail("missing \"Intent-slug:\" line")
  if (!lang_seen) fail("missing \"Language:\" line")
  nfr = 0
  for (i = 1; i <= ndef; i++) if (prefix(deflist[i]) == "FR") nfr++
  if (nfr == 0) fail("section 3 has no FR-xx requirement")
  for (i = 1; i <= ndef; i++) {
    id = deflist[i]; p = prefix(id)
    if (p == "FR") {
      if (!(id in frcov)) fail(id " (line " defd[id] ") has no acceptance criterion")
      if (!(id in trcov)) fail(id " (line " defd[id] ") is not referenced by any task")
    } else if (p == "NFR" || p == "C" || p == "D") {
      if (!(id in trcov)) fail(id " (line " defd[id] ") is not referenced by any task")
    }
  }
  for (i = 1; i <= nchk; i++)
    if (!(chk_ref[i] in defd)) fail(chk_owner[i] " (line " chk_line[i] ") references unknown " chk_ref[i])
  for (i = 1; i <= nac; i++) {
    id = aclist[i]
    if (!(id in row9)) fail(id " (line " ac[id] ") has no verification row in section 9")
  }
  for (k in row9)
    if (!(k in ac)) fail("section 9 row " k " (line " row9[k] ") has no matching acceptance criterion")
  for (q in cited)
    if (!(q in logged)) fail(q " (first cited at line " cited[q] ") has no row in the decision log")
  if (fails == 0) { print "RESULT: OK"; exit 0 }
  print "RESULT: " fails " issue(s) found"
  exit 1
}
' "$1"
