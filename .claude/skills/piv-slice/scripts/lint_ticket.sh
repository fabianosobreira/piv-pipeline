#!/bin/sh
# lint_ticket.sh - check that a ticket is a verbatim slice of its spec.
# Usage: sh scripts/lint_ticket.sh [ticket.md] [spec.md]
# Exit codes: 0 = no findings, 1 = findings, 2 = usage or I/O error.
# Output: one "FAIL line N: [message]" per problem, then "RESULT: OK" or
# "RESULT: N issue(s) found".
#
# The ticket is a header block (a markdown list, one bold label per line)
# followed by the 10 sections of the spec (9 numbered ones and the appendix).
# The header holds what piv-slice writes: "Task" (one T-xx id), "Title",
# "Type" (bug, feature or none), "Blocked by" ("none" or T-xx ids), "Size"
# (S, M or L), "DoD" (the AC ids the task proves) and "Cites" ("none" or the
# NFR, C and D ids it needs). A line of a section passes only if it is a line
# of the same section of the spec; a line the ticket does not pull in, or a
# line it pulls in and drops, is a finding. A section with no content holds the
# single line "None in this ticket.".
# Slice rules: sections 1, 2 and the Always / Ask first / Never levels are
# copied whole; AC only when the DoD names it; FR only when an AC of the DoD
# cites it; NFR, C and D only when Cites names them; section 9 rows of the DoD
# AC; open questions that cite an ID the ticket carries; decision-log rows of
# every Q the ticket cites. Coverage across tickets is lint_epic.sh's job.

if [ "$#" -ne 2 ]; then
  echo "usage: lint_ticket.sh [ticket.md] [spec.md]" >&2
  exit 2
fi
for f in "$1" "$2"; do
  if [ ! -r "$f" ] || [ ! -s "$f" ]; then
    echo "error: cannot read '$f', or it is empty" >&2
    exit 2
  fi
done

# The revision the ticket must name: the spec's blob hash, with no filters so
# that the hash does not depend on the checkout's line-ending settings.
spec_hash=$(git hash-object --no-filters "$2" 2>/dev/null) || {
  echo "error: cannot hash '$2' with git hash-object" >&2
  exit 2
}

# A ticket in CRLF would pass a text-mode awk as verbatim; bytes are checked here.
cr_at=$(tr -d '\015' < "$1" | cmp - "$1" 2>/dev/null)
if [ -n "$cr_at" ]; then
  echo "FAIL line ${cr_at##* }: the ticket has CR line endings; write it with LF"
  echo "RESULT: 1 issue(s) found"
  exit 1
fi

LC_ALL=C awk -v spec_hash="$spec_hash" -v spec_path="$2" '
function fail(msg) { print "FAIL: " msg; fails++ }
function err(msg) { print "FAIL line " TNR ": " msg; fails++ }
function errl(s) { print "FAIL line " s; fails++ }

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

function prefix(id) { sub(/-[0-9]+$/, "", id); return id }
function trim(s) { gsub(/^[ \t`]+|[ \t`]+$/, "", s); return s }

# The unit a line belongs to: a section, or one level of section 8.
function ukey(s, sb) { return (s == 8) ? "8/" sb : s "" }

# Section number of a "## " heading line, 0 when it is none of the 10.
function heading_sec(s) {
  if (s ~ /^## Appendix/) return 10
  if (s ~ /^## [0-9]+\./) { split(s, w, " "); return w[2] + 0 }
  return 0
}

function short(s) { return (length(s) > 50) ? substr(s, 1, 50) "..." : s }

BEGIN { split("", w) }

FNR == 1 { nf++ }
nf == 1 { sub(/\r$/, "") }

# ---------------------------------------------------------------- spec pass
nf == 1 {
  if ($0 ~ /^## /) {
    sec = heading_sec($0); sb = ""
    if (sec > 0) { shead[sec] = $0; sseen[sec] = 1 }
    next
  }
  if (sec == 0) {
    if ($0 ~ /^Intent-slug:/) sp_slug = trim(substr($0, 13))
    if ($0 ~ /^Language:/) sp_lang = trim(substr($0, 10))
    next
  }
  if (sec == 8 && $0 ~ /^### /) {
    sb = substr($0, 5); subline[sb] = $0; subs[++nsubs] = sb
    next
  }
  if ($0 ~ /^[ \t]*$/) next
  u = ukey(sec, sb)
  n = ++scount[u]
  stext[u, n] = $0; snr[u, n] = FNR
  if (!((u, $0) in sidx)) sidx[u, $0] = n
  id = ""; ishd = 0
  if (sec == 3 && match($0, /^- FR-[0-9]+/)) id = substr($0, 3, RLENGTH - 2)
  else if (sec == 5 && match($0, /^- NFR-[0-9]+/)) id = substr($0, 3, RLENGTH - 2)
  else if (sec == 4 && match($0, /^- AC-[0-9]+/)) id = substr($0, 3, RLENGTH - 2)
  else if (sec == 6 && match($0, /^- C-[0-9]+/)) id = substr($0, 3, RLENGTH - 2)
  else if (sec == 7 && match($0, /^- D-[0-9]+/)) id = substr($0, 3, RLENGTH - 2)
  else if (sec == 9 || sec == 10) {
    if ($0 ~ /^\|/) {
      split($0, c, "|"); k = trim(c[2])
      if ((sec == 9 && k ~ /^AC-[0-9]+$/) || (sec == 10 && k ~ /^Q[0-9]+$/)) id = k
      else ishd = 1
    }
  }
  sid[u, n] = id; shd[u, n] = ishd
  if (id != "") sdef[id] = n
  if (sec == 4 && id != "") {
    nn = collect(head($0), "[A-Z]+-[0-9]+", refs)
    acfr[id] = ""
    for (i = 1; i <= nn; i++) if (prefix(refs[i]) == "FR") acfr[id] = acfr[id] " " refs[i] " "
  }
  next
}

# -------------------------------------------------------------- ticket pass
{ TNR = FNR }

# Header block: everything before the first "## " heading.
!tstarted && $0 !~ /^## / {
  if ($0 ~ /^[ \t]*$/) next
  if (!match($0, /^- \*\*[A-Za-z -]+\*\*: /)) {
    err("header line is not \"- **Label**: value\"")
    next
  }
  lab = substr($0, 5, RLENGTH - 8); val = trim(substr($0, RLENGTH + 1))
  if (lab !~ /^(Spec|Task|Title|Type|Blocked by|Size|DoD|Cites|Intent-slug|Language)$/) { err("unknown header label \"" lab "\""); next }
  if (lab in hval) { err("duplicate header label \"" lab "\""); next }
  hval[lab] = val; hline[lab] = FNR
  if (val == "") err("header label \"" lab "\" has no value")
  next
}

$0 ~ /^## / {
  tstarted = 1
  tsec = heading_sec($0); tsub = ""
  if (tsec == 0 || !(tsec in shead) || $0 != shead[tsec]) { err("heading is not a heading of the spec"); tsec = -1; next }
  if (tsec in tsawh) err("duplicate heading")
  if (tsec < lastsec) err("heading out of order")
  lastsec = tsec; tsawh[tsec] = FNR
  next
}

$0 ~ /^### / && tsec == 8 {
  name = substr($0, 5)
  if (!(name in subline) || $0 != subline[name]) { err("heading is not a level of section 8 of the spec"); tsub = "?"; next }
  if (name in tsawsub) err("duplicate heading")
  tsawsub[name] = FNR; tsub = name
  next
}

/^[ \t]*$/ { next }

/\[PENDING\]/ { err("unresolved [PENDING] marker") }

{
  if (tsec <= 0) { err("content outside a section of the spec"); next }
  u = ukey(tsec, tsub)
  if ($0 == "None in this ticket.") {
    if (u in tmark) err("None in this ticket. appears twice in the same section")
    tmark[u] = FNR
    next
  }
  tn[u]++
  if (!((u, $0) in sidx)) { err("not a verbatim line of the spec"); next }
  idx = sidx[u, $0]
  if ((u, idx) in tseen) { err("line is copied twice"); next }
  tseen[u, idx] = FNR
  if (idx < tlast[u]) err("line is out of the spec order")
  tlast[u] = idx
  if (tsec <= 9) {
    nn = collect($0, "Q[0-9]+", qs)
    for (i = 1; i <= nn; i++) citedq[qs[i]] = 1
  }
}

# ---------------------------------------------------------------------- end
END {
  if (nf < 2) { fail("the ticket has no lines"); finish() }

  # Header block.
  nreq = split("Spec|Task|Title|Type|Blocked by|Size|DoD|Cites|Intent-slug|Language", req, "|")
  for (i = 1; i <= nreq; i++) if (!(req[i] in hval)) fail("header is missing \"" req[i] "\"")
  if ("Type" in hval && hval["Type"] !~ /^(bug|feature|none)$/)
    errl(hline["Type"] ": Type must be bug, feature or none")
  if ("Size" in hval && hval["Size"] !~ /^(S|M|L)$/)
    errl(hline["Size"] ": Size must be S, M or L")
  if ("Spec" in hval) {
    sv = hval["Spec"]
    if (!match(sv, / @ [0-9a-f]+$/) || RSTART < 2) {
      errl(hline["Spec"] ": Spec must read \"[path] @ [hash]\"")
    } else {
      got = substr(sv, RSTART + 3)
      pth = substr(sv, 1, RSTART - 1); sub(/.*\//, "", pth); want_base = spec_path; sub(/.*\//, "", want_base)
      if (pth != want_base) errl(hline["Spec"] ": Spec path " substr(sv, 1, RSTART - 1) " is not the spec " spec_path)
      if (got != spec_hash) errl(hline["Spec"] ": Spec hash " got " is not the spec revision " spec_hash)
    }
  }
  if ("Intent-slug" in hval && hval["Intent-slug"] != sp_slug)
    errl(hline["Intent-slug"] ": Intent-slug is not the spec Intent-slug (" sp_slug ")")
  if ("Language" in hval && hval["Language"] != sp_lang)
    errl(hline["Language"] ": Language is not the spec Language (" sp_lang ")")
  if ("Task" in hval && hval["Task"] !~ /^T-[0-9]+$/)
    errl(hline["Task"] ": Task must be one task id (T-xx); a ticket carries exactly one task")
  if ("Blocked by" in hval) {
    if (hval["Blocked by"] != "none" && hval["Blocked by"] !~ /^T-[0-9]+(, *T-[0-9]+)*$/)
      errl(hline["Blocked by"] ": Blocked by must be \"none\" or task ids (T-xx) separated by commas")
    else if (hval["Blocked by"] != "none") {
      nblk = split(hval["Blocked by"], bl, /, */)
      for (i = 1; i <= nblk; i++) {
        if (bl[i] in blseen) errl(hline["Blocked by"] ": " bl[i] " is named twice in Blocked by")
        if ("Task" in hval && bl[i] == hval["Task"]) errl(hline["Blocked by"] ": a task cannot block itself")
        blseen[bl[i]] = 1
      }
    }
  }

  # What the ticket pulls in: the AC of its DoD, the FR those AC cite, and the
  # NFR, C and D it cites.
  if ("DoD" in hval) {
    if (hval["DoD"] !~ /^AC-[0-9]+(, *AC-[0-9]+)*$/)
      errl(hline["DoD"] ": DoD must be acceptance criteria ids (AC-xx) separated by commas")
    else {
      nd = split(hval["DoD"], dl, /, */)
      for (i = 1; i <= nd; i++) {
        a = dl[i]
        if (a in dseen) { errl(hline["DoD"] ": " a " is named twice in DoD"); continue }
        dseen[a] = 1
        if (!(a in acfr)) { errl(hline["DoD"] ": " a " is not an acceptance criterion of the spec"); continue }
        want_id[a] = 1
        nn = split(acfr[a], fr, " ")
        for (j = 1; j <= nn; j++) {
          if (!(fr[j] in sdef)) fail(a " cites " fr[j] ", which the spec does not define")
          want_id[fr[j]] = 1
        }
      }
    }
  }
  if ("Cites" in hval && hval["Cites"] != "none") {
    if (hval["Cites"] !~ /^(NFR|C|D)-[0-9]+(, *(NFR|C|D)-[0-9]+)*$/)
      errl(hline["Cites"] ": Cites must be \"none\" or NFR, C or D ids separated by commas")
    else {
      nc = split(hval["Cites"], cl, /, */)
      for (i = 1; i <= nc; i++) {
        if (cl[i] in cseen) { errl(hline["Cites"] ": " cl[i] " is named twice in Cites"); continue }
        cseen[cl[i]] = 1
        if (!(cl[i] in sdef)) { errl(hline["Cites"] ": " cl[i] " is not an item of the spec"); continue }
        want_id[cl[i]] = 1
      }
    }
  }
  # Decision-log rows of the Q the ticket cites.
  for (q in citedq) {
    if (!(q in sdef)) fail(q " is cited but has no row in the decision log of the spec")
    else want_id[q] = 1
  }

  # Per unit: which spec lines the ticket wants, against which it has.
  nu = 0
  for (s = 1; s <= 10; s++) {
    if (!(s in sseen)) continue
    if (s == 8) { for (i = 1; i <= nsubs; i++) units[++nu] = "8/" subs[i] }
    else units[++nu] = s ""
  }
  for (k = 1; k <= nu; k++) {
    u = units[k]
    sec_of = (u ~ /^8\//) ? 8 : u + 0
    # Does the unit hold any wanted content line? (decides the table header)
    anyrow = 0
    for (n = 1; n <= scount[u]; n++) if (wanted(u, n, sec_of) && !shd[u, n]) anyrow = 1
    wantn = 0
    for (n = 1; n <= scount[u]; n++) {
      wn = wanted(u, n, sec_of)
      if (shd[u, n]) wn = anyrow
      if (wn) wantn++
      if (wn && !((u, n) in tseen)) fail("section " label(u) " is missing the spec line " snr[u, n] " (" short(stext[u, n]) ")")
      if (!wn && ((u, n) in tseen)) errl(tseen[u, n] ": the ticket does not pull in this line of the spec")
    }
    if (wantn == 0 && !(u in tmark)) {
      if (u ~ /^8\//) { if (substr(u, 3) in tsawsub) errl(tsawsub[substr(u, 3)] ": section " label(u) " has no content for the ticket: write None in this ticket.") }
      else if ((u + 0) in tsawh) errl(tsawh[u + 0] ": section " label(u) " has no content for the ticket: write None in this ticket.")
    }
    if (wantn > 0 && (u in tmark))
      errl(tmark[u] ": None in this ticket. is used in section " label(u) ", which has content for the ticket")
    if (wantn == 0 && (u in tmark) && tn[u] > 0)
      errl(tmark[u] ": None in this ticket. shares section " label(u) " with other content")
    # Every section and level of the spec appears in the ticket.
    if (u ~ /^8\//) { if (!(substr(u, 3) in tsawsub)) fail("the ticket has no \"" subline[substr(u, 3)] "\" level") }
    else if (!((u + 0) in tsawh)) fail("the ticket has no \"" shead[u + 0] "\" heading")
  }
  finish()
}

function label(u) { return (u ~ /^8\//) ? "8 / " substr(u, 3) : u }

# Does the ticket pull in line n of unit u?
function wanted(u, n, s,    id, nn, i) {
  id = sid[u, n]
  if (s == 1 || s == 2) return 1
  if (u == "8/Open questions") {
    nn = collect(stext[u, n], "[A-Z]+-[0-9]+", refs2)
    for (i = 1; i <= nn; i++) if (refs2[i] in want_id) return 1
    return 0
  }
  if (s == 8) return 1
  if (s == 3 || s == 4 || s == 5 || s == 6 || s == 7 || s == 9 || s == 10) {
    if (shd[u, n]) return 0
    if (id == "") return 0
    return (id in want_id)
  }
  return 0
}

function finish() {
  if (fails == 0) { print "RESULT: OK"; exit 0 }
  print "RESULT: " fails " issue(s) found"
  exit 1
}
' "$2" "$1"
