#!/usr/bin/env bash
# Tests lint_epic.sh against throwaway intent directories holding a spec, an epic and
# the headers of the tickets cut from it. Each case builds its own directory.
#
# Usage: lint_epic.test.sh
# Needs: bash and awk. Touches nothing outside a temporary directory.
# Exit: 0 = every case passed, 1 = at least one failed (one line per failure on stderr).

set -eu

here=$(cd "$(dirname "$0")" && pwd)
script=$here/lint_epic.sh
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT

failures=0
count=0
out=
code=0

# The spec: three AC, one NFR, one C and one D. Only the IDs matter to the script.
write_spec() {
  cat > "$1" <<'EOF'
# Spec: Demo

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client sends request 101 THE SYSTEM SHALL respond with HTTP 429.
- FR-03 (Source: Q4): WHEN the limiter is disabled THE SYSTEM SHALL pass all requests.

## 4. Acceptance criteria
- AC-01 (FR-01, Source: Q6): Given 100 requests When request 101 arrives Then the status is 429.
- AC-02 (FR-01, Source: Q6): Given a blocked client When the minute ends Then request 102 passes.
- AC-03 (FR-01, Source: Q6): Given a blocked client When the minute ends Then the Retry-After header is gone.

## 5. Non-functional requirements
- NFR-01 (Source: Q5): Added latency p95 below 5 ms.

## 6. Technical constraints
- C-01 (Source: Q7): Node 20 and vitest.

## 7. Design
- D-01 (Source: Q8): Middleware in src/middleware/rate-limit.js.

## 8. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Open questions
- Should FR-01 count retries? (Source: Q12)
- Should the limiter log a warning? (Source: Q12)

## Appendix: Decision log
EOF
}

# The epic: T-01, then T-02 blocked by T-01, sized M.
write_epic() {
  cat > "$1" <<'EOF'
- **Intent-slug**: demo
- **Spec**: .piv/demo/spec.md @ @HASH@

## Context
Show the slicing.

## Tasks
- [ ] T-01 — Reject request 101 | feature | S | Depends on: -
- [ ] T-02 — Reset the limit when the minute ends | feature | M | Depends on: T-01

## Large tasks
None.

## Deferrals
None.

## Not ticketed
- Should the limiter log a warning? It cites no ID.
EOF
}

# write_ticket [file] [task] [title] [size] [blocked by] [dod] [cites]: the header of a ticket.
write_ticket() {
  mkdir -p "$(dirname "$1")"
  cat > "$1" <<EOF
- **Spec**: .piv/demo/spec.md @ @HASH@
- **Task**: $2
- **Title**: $3
- **Type**: feature
- **Blocked by**: $5
- **Size**: $4
- **DoD**: $6
- **Cites**: $7
- **Intent-slug**: demo
- **Language**: en-US

## 1. Goal and context
- Show the slicing. (Source: Q1)
EOF
}

# new_case [name]: an intent directory with a valid cut; entered.
new_case() {
  mkdir -p "$root/$1/demo"
  cd "$root/$1/demo"
  write_spec spec.md
  write_epic epic.md
  write_ticket tasks/T-01/T-01.md T-01 "Reject request 101" S none "AC-01" "C-01"
  write_ticket tasks/T-02/T-02.md T-02 "Reset the limit when the minute ends" M T-01 "AC-02, AC-03" "NFR-01, D-01"
  h=$(git hash-object --no-filters spec.md)
  sed -i "s/@HASH@/$h/" epic.md tasks/T-01/T-01.md tasks/T-02/T-02.md
}

run() {
  code=0
  out=$(sh "$script" . 2>&1) || code=$?
}

pass() {
  count=$((count + 1))
  run
  if [ "$code" -ne 0 ] || [ "$out" != "RESULT: OK" ]; then
    echo "FAIL: $1: expected exit 0 and RESULT: OK, got exit $code: $out" >&2
    failures=$((failures + 1))
  fi
}

reject() {
  count=$((count + 1))
  run
  case $out in
    *"$2"*"RESULT: "*" issue(s) found") ;;
    *) echo "FAIL: $1: expected exit 1 with '$2', got exit $code: $out" >&2; failures=$((failures + 1)); return ;;
  esac
  if [ "$code" -ne 1 ]; then
    echo "FAIL: $1: expected exit 1, got exit $code: $out" >&2
    failures=$((failures + 1))
  fi
}

new_case valid
pass "a cut that covers the spec"

new_case report-beside-ticket
echo "- not a ticket" > tasks/T-01/T-01.report.md
pass "a report beside a ticket is not a ticket"

new_case done-line
sed -i 's/^- \[ \] T-01 — \(.*\)$/- [x] T-01 — \1 — commits: a1b2c3d/' epic.md
pass "a task already done keeps its line parsed"

new_case ticket-missing
rm -r tasks/T-02
reject "a task with no ticket" "T-02 has no ticket"

new_case ticket-extra
write_ticket tasks/T-03/T-03.md T-03 "Extra" S none "AC-01" "none"
reject "a ticket with no task in the epic" "the ticket of T-03 has no task in the epic"

new_case title-differs
sed -i 's/^- \*\*Title\*\*: Reject request 101/- **Title**: Reject the request/' tasks/T-01/T-01.md
reject "a ticket Title that differs from the epic" "T-01: the ticket Title differs"

new_case size-differs
sed -i 's/^- \*\*Size\*\*: S/- **Size**: M/' tasks/T-01/T-01.md
reject "a ticket Size that differs from the epic" "T-01: the ticket Size differs"

new_case blocked-differs
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: none/' tasks/T-02/T-02.md
reject "a Blocked by that differs from the epic Depends on" "T-02: the ticket Blocked by differs"

new_case depends-forward
sed -i 's/Depends on: -$/Depends on: T-02/; s/Depends on: T-01$/Depends on: -/' epic.md
sed -i 's/^- \*\*Blocked by\*\*: none/- **Blocked by**: T-02/' tasks/T-01/T-01.md
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: none/' tasks/T-02/T-02.md
reject "a dependency on a later task" "T-01 depends on T-02, which does not come before it"

new_case depends-unknown
sed -i 's/Depends on: T-01$/Depends on: T-09/' epic.md
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: T-09/' tasks/T-02/T-02.md
reject "a dependency on a task the epic lacks" "T-02 depends on T-09, which the epic does not list"

new_case ac-uncovered
sed -i 's/^- \*\*DoD\*\*: AC-02, AC-03/- **DoD**: AC-03/' tasks/T-02/T-02.md
reject "an AC in no DoD" "AC-02 is in the DoD of no ticket"

new_case ac-twice
sed -i 's/^- \*\*DoD\*\*: AC-01/- **DoD**: AC-01, AC-02/' tasks/T-01/T-01.md
reject "an AC in two DoD" "AC-02 is in the DoD of 2 tickets"

new_case ac-unknown
sed -i 's/^- \*\*DoD\*\*: AC-01/- **DoD**: AC-01, AC-09/' tasks/T-01/T-01.md
reject "a DoD naming an AC the spec lacks" "a DoD names AC-09"

new_case nfr-uncited
sed -i 's/^- \*\*Cites\*\*: NFR-01, D-01/- **Cites**: D-01/' tasks/T-02/T-02.md
reject "an NFR in no Cites" "NFR-01 is in the Cites of no ticket"

new_case design-uncited
sed -i 's/^- \*\*Cites\*\*: C-01/- **Cites**: none/' tasks/T-01/T-01.md
reject "a C in no Cites" "C-01 is in the Cites of no ticket"

new_case large-without-reason
sed -i 's/^- \[ \] T-02 — \(.*\) | M |/- [ ] T-02 — \1 | L |/' epic.md
sed -i 's/^- \*\*Size\*\*: M/- **Size**: L/' tasks/T-02/T-02.md
reject "a task sized L with no Large tasks line" "T-02 is sized L but Large tasks gives no reason"

new_case large-with-reason
sed -i 's/^- \[ \] T-02 — \(.*\) | M |/- [ ] T-02 — \1 | L |/' epic.md
sed -i 's/^- \*\*Size\*\*: M/- **Size**: L/' tasks/T-02/T-02.md
sed -i 's/^None\.$/- T-02 — The switch and the reset share one migration, so neither is provable alone./;' epic.md
sed -i '0,/^- T-02 — The switch/!{/^- T-02 — The switch/s/.*/None./}' epic.md
pass "a task sized L with its reason"

new_case large-not-large
sed -i '0,/^None\.$/s//- T-01 — Reason that no longer applies./' epic.md
reject "a Large tasks line for a task not sized L" "T-01 is in Large tasks but is not sized L"

new_case no-task
sed -i '/^- \[ \] T-/d' epic.md
reject "an epic with no task" "the epic lists no task"

new_case task-twice
sed -i '/^- \[ \] T-01 /p' epic.md
reject "a task listed twice" "the epic lists T-01 twice"

new_case ticket-ids-swapped
sed -i 's/^- \*\*Task\*\*: T-01/- **Task**: T-XX/; s/^- \*\*Task\*\*: T-02/- **Task**: T-01/' tasks/T-01/T-01.md tasks/T-02/T-02.md
sed -i 's/^- \*\*Task\*\*: T-XX/- **Task**: T-02/' tasks/T-01/T-01.md tasks/T-02/T-02.md
reject "tickets whose Task disagrees with their file name" "the file name and the Task must agree"

new_case task-missing
sed -i '/^- \*\*Task\*\*:/d' tasks/T-02/T-02.md
reject "a ticket with no Task, named by its file" "T-02.md has no Task in its header"

new_case dod-twice-in-one-ticket
sed -i 's/^- \*\*DoD\*\*: AC-01/- **DoD**: AC-01, AC-01/' tasks/T-01/T-01.md
pass "an AC named twice in one DoD is lint_ticket.sh's finding, not a second ticket"

new_case epic-hash-stale
sed -i 's/^\(- \*\*Spec\*\*: .* @ \).*/\10000000000000000000000000000000000000000/' epic.md
reject "an epic cut from another spec revision" "the epic Spec hash"

new_case epic-spec-missing
sed -i '/^- \*\*Spec\*\*:/d' epic.md
reject "an epic with no Spec line" "the epic has no Spec line"

new_case ticket-hash-stale
sed -i 's/^\(- \*\*Spec\*\*: .* @ \).*/\10000000000000000000000000000000000000000/' tasks/T-01/T-01.md
reject "a ticket cut from another spec revision" "T-01: the ticket Spec hash is not the spec revision"

new_case not-ticketed-missing
sed -i 's/^- Should the limiter log a warning?.*/None./' epic.md
reject "an open question no ticket carries and Not ticketed omits" "is carried by no ticket and is not under Not ticketed"

new_case usage
for args in "" ". extra" "missing"; do
  count=$((count + 1))
  code=0
  # shellcheck disable=SC2086
  sh "$script" $args > /dev/null 2>&1 || code=$?
  if [ "$code" -ne 2 ]; then
    echo "FAIL: usage '$args': expected exit 2, got exit $code" >&2
    failures=$((failures + 1))
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "$failures of $count cases failed" >&2
  exit 1
fi
echo "all $count cases passed"
