#!/bin/sh
# lint_epic.sh - check that the tickets of an intent cover its spec and agree with its epic.
# Usage: sh scripts/lint_epic.sh [intent-dir]    (such as .piv/[intent-slug])
# Reads [intent-dir]/spec.md, [intent-dir]/epic.md and every ticket at
# [intent-dir]/tasks/T-xx/T-xx.md. lint_ticket.sh checks each ticket against the
# spec; this checks the cut as a whole.
# Exit codes: 0 = no findings, 1 = findings, 2 = usage or I/O error.
# Needs: POSIX sh, awk and git.
# Output: one "FAIL: [message]" per problem, then "RESULT: OK" or
# "RESULT: N issue(s) found".
#
# Rules:
# - Every task of the epic has a ticket, every ticket has a task, and the ticket
#   header agrees with the epic line on Title, Type, Size and Blocked by / Depends on.
# - A task depends only on tasks listed before it, so the order is a valid
#   execution order and no dependency is a cycle.
# - Every AC of the spec is in the DoD of exactly one ticket; every NFR, C and D
#   is in the Cites of at least one ticket.
# - Every task sized L has a line under "Large tasks" with the reason; no other does.
# - The Spec hash of the epic and of every ticket is the hash of the spec on disk.
# - Every open question of section 8 that cites no ID a ticket carries is listed
#   under "Not ticketed". A ticket carries its DoD AC, the FR they cite and its Cites.

if [ "$#" -ne 1 ]; then
  echo "usage: lint_epic.sh [intent-dir]" >&2
  exit 2
fi
dir=${1%/}
for f in "$dir/epic.md" "$dir/spec.md"; do
  if [ ! -r "$f" ] || [ ! -s "$f" ]; then
    echo "error: cannot read '$f', or it is empty" >&2
    exit 2
  fi
done

spec_hash=$(git hash-object --no-filters "$dir/spec.md" 2>/dev/null) || {
  echo "error: cannot hash '$dir/spec.md' with git hash-object" >&2
  exit 2
}

set -- "$dir/epic.md" "$dir/spec.md"
for t in "$dir"/tasks/T-*/T-*.md; do
  [ -f "$t" ] || continue
  b=${t##*/}; b=${b%.md}
  case $b in *.*) continue ;; esac
  set -- "$@" "$t"
done

LC_ALL=C awk -v spec_hash="$spec_hash" '
function fail(msg) { print "FAIL: " msg; fails++ }

# The hash after " @ " in a Spec header value, or "" when there is none.
function spec_at(v) { return match(v, / @ [0-9a-f]+$/) ? substr(v, RSTART + 3) : "" }

# Fill ids with every ID such as FR-01 or NFR-02 in s; return the count.
function ids_of(s, ids,    n) {
  split("", ids); n = 0
  while (match(s, /[A-Z]+-[0-9]+/)) { ids[++n] = substr(s, RSTART, RLENGTH); s = substr(s, RSTART + RLENGTH) }
  return n
}
function trim(s) { gsub(/^[ \t`]+|[ \t`]+$/, "", s); return s }
function prefix(id) { sub(/-[0-9]+$/, "", id); return id }

FNR == 1 { nf++; sec = 0; intasks = 0; inlarge = 0; innt = 0; inoq = 0; tfile[nf] = FILENAME }

# ---------------------------------------------------------------- the epic
nf == 1 {
  if ($0 ~ /^## /) {
    intasks = ($0 ~ /^## Tasks[ ]*$/); inlarge = ($0 ~ /^## Large tasks[ ]*$/); innt = ($0 ~ /^## Not ticketed[ ]*$/)
    next
  }
  if (innt && $0 ~ /^- /) { nt[++nnt] = $0; next }
  if (!intasks && !inlarge && !innt && $0 ~ /^- \*\*Spec\*\*: /) { espec = spec_at($0); espec_seen = 1; next }
  if (intasks && match($0, /^- \[[ ~x]\] T-[0-9]+ — /)) {
    line = $0
    id = substr(line, 7); sub(/ —.*/, "", id)
    if (id in etitle) { fail("the epic lists " id " twice"); next }
    rest = substr(line, RLENGTH + 1)
    sub(/ — commits:.*$/, "", rest)
    n = split(rest, f, / \| /)
    etitle[id] = f[1]; etype[id] = f[2]; esize[id] = f[3]
    edep[id] = f[4]; sub(/^Depends on: /, "", edep[id])
    eorder[++ntask] = id; epos[id] = ntask
    next
  }
  if (inlarge && match($0, /^- T-[0-9]+ — /)) {
    id = substr($0, 3); sub(/ —.*/, "", id)
    if (id in elarge) fail("Large tasks lists " id " twice")
    elarge[id] = 1
    if (trim(substr($0, RLENGTH + 1)) == "") fail("Large tasks line of " id " gives no reason")
    next
  }
  next
}

# ---------------------------------------------------------------- the spec
nf == 2 {
  if ($0 ~ /^## Appendix/) { sec = 99; inoq = 0; next }
  if ($0 ~ /^## [0-9]+\./) { sec = $2 + 0; inoq = 0; next }
  if (sec == 8 && $0 ~ /^### /) { inoq = ($0 ~ /^### Open questions[ ]*$/); next }
  if (sec == 8 && inoq && $0 ~ /^- / && $0 !~ /^- None\./) { oq[++noq] = $0; next }
  if (sec == 4 && match($0, /^- AC-[0-9]+/)) {
    aid = substr($0, 3, RLENGTH - 2); sacs[aid] = 1
    a = index($0, "("); b = index($0, "):")
    acfr[aid] = (a > 0 && b > a) ? substr($0, a + 1, b - a - 1) : ""
  }
  if (sec == 5 && match($0, /^- NFR-[0-9]+/)) { sother[substr($0, 3, RLENGTH - 2)] = 1 }
  if (sec == 6 && match($0, /^- C-[0-9]+/)) { sother[substr($0, 3, RLENGTH - 2)] = 1 }
  if (sec == 7 && match($0, /^- D-[0-9]+/)) { sother[substr($0, 3, RLENGTH - 2)] = 1 }
  next
}

# ---------------------------------------------------------------- the tickets
nf >= 3 {
  if ($0 ~ /^## /) { hdone[nf] = 1; next }
  if (hdone[nf]) next
  if (!match($0, /^- \*\*[A-Za-z -]+\*\*: /)) next
  lab = substr($0, 5, RLENGTH - 8); val = trim(substr($0, RLENGTH + 1))
  if (lab == "Task") tid[nf] = val
  else tval[nf, lab] = val
}

END {
  if (ntask == 0) fail("the epic lists no task")

  for (k = 3; k <= nf; k++) {
    id = tid[k]
    if (id == "") { fail(tfile[k] " has no Task in its header"); continue }
    base = tfile[k]; sub(/.*[\/\\]/, "", base); sub(/\.md$/, "", base)
    if (base != id) fail(tfile[k] " carries Task " id "; the file name and the Task must agree")
    if (id in tk) { fail(id " has two tickets"); continue }
    tk[id] = k
    if (!(id in etitle)) fail("the ticket of " id " has no task in the epic")
  }

  for (i = 1; i <= ntask; i++) {
    id = eorder[i]
    if (!(id in tk)) { fail(id " has no ticket"); continue }
    k = tk[id]
    if (tval[k, "Title"] != etitle[id]) fail(id ": the ticket Title differs from the epic title")
    if (tval[k, "Type"] != etype[id]) fail(id ": the ticket Type differs from the epic type")
    if (tval[k, "Size"] != esize[id]) fail(id ": the ticket Size differs from the epic size")
    want = (edep[id] == "-") ? "none" : edep[id]
    gsub(/ /, "", want); have = tval[k, "Blocked by"]; gsub(/ /, "", have)
    if (have != want) fail(id ": the ticket Blocked by differs from the epic Depends on")
    if (edep[id] != "-") {
      nd = split(edep[id], dl, /, */)
      for (j = 1; j <= nd; j++) {
        if (!(dl[j] in epos)) fail(id " depends on " dl[j] ", which the epic does not list")
        else if (epos[dl[j]] >= i) fail(id " depends on " dl[j] ", which does not come before it")
      }
    }
    if (esize[id] == "L" && !(id in elarge)) fail(id " is sized L but Large tasks gives no reason")
    if (esize[id] != "L" && (id in elarge)) fail(id " is in Large tasks but is not sized L")
  }
  for (id in elarge) if (!(id in etitle)) fail("Large tasks lists " id ", which the epic does not list")

  for (k = 3; k <= nf; k++) {
    if (tid[k] == "") continue
    if (tval[k, "DoD"] != "") {
      nd = split(tval[k, "DoD"], dl, /, */)
      for (j = 1; j <= nd; j++) {
        if ((k, dl[j]) in dseen) continue
        dseen[k, dl[j]] = 1; dodcount[dl[j]]++
      }
    }
    if (tval[k, "Cites"] != "" && tval[k, "Cites"] != "none") {
      nc = split(tval[k, "Cites"], cl, /, */)
      for (j = 1; j <= nc; j++) cited[cl[j]] = 1
    }
  }
  for (a in sacs) {
    if (!(a in dodcount)) fail(a " is in the DoD of no ticket")
    else if (dodcount[a] > 1) fail(a " is in the DoD of " dodcount[a] " tickets; one ticket proves it")
  }
  for (a in dodcount) if (!(a in sacs)) fail("a DoD names " a ", which the spec does not define")
  for (x in sother) if (!(x in cited)) fail(x " is in the Cites of no ticket")

  # The spec revision every artifact was cut from.
  if (!espec_seen) fail("the epic has no Spec line")
  else if (espec != spec_hash) fail("the epic Spec hash " espec " is not the spec revision " spec_hash)
  for (k = 3; k <= nf; k++) {
    if (tid[k] == "") continue
    if (spec_at(tval[k, "Spec"]) != spec_hash) fail(tid[k] ": the ticket Spec hash is not the spec revision " spec_hash)
  }

  # An open question no ticket carries is listed under Not ticketed. A ticket
  # carries its DoD AC, the FR those AC cite, and its Cites.
  for (k = 3; k <= nf; k++) {
    if (tid[k] == "" || tval[k, "DoD"] == "") continue
    nd = split(tval[k, "DoD"], dl, /, */)
    for (j = 1; j <= nd; j++) {
      carried[dl[j]] = 1
      nn = ids_of(acfr[dl[j]], frs)
      for (m = 1; m <= nn; m++) carried[frs[m]] = 1
    }
    if (tval[k, "Cites"] != "" && tval[k, "Cites"] != "none") {
      nc = split(tval[k, "Cites"], cl, /, */)
      for (j = 1; j <= nc; j++) carried[cl[j]] = 1
    }
  }
  for (q = 1; q <= noq; q++) {
    nn = ids_of(oq[q], qids); held = 0
    for (m = 1; m <= nn; m++) if (qids[m] in carried) held = 1
    if (held) continue
    text = substr(oq[q], 3); sub(/ \(Source: .*$/, "", text)
    listed = 0
    for (m = 1; m <= nnt; m++) if (index(nt[m], text) > 0) listed = 1
    if (!listed) fail("the open question \"" text "\" is carried by no ticket and is not under Not ticketed")
  }

  if (fails == 0) { print "RESULT: OK"; exit 0 }
  print "RESULT: " fails " issue(s) found"
  exit 1
}
' "$@"
