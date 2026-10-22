#!/usr/bin/env bash
# Tests lint_ticket.sh against throwaway directories holding a synthetic spec and
# tickets cut from it. Each case builds its own directory, so no case sees another's.
#
# Usage: lint_ticket.test.sh
# Needs: bash, git and awk. Touches nothing outside a temporary directory.
# Exit: 0 = every case passed, 1 = at least one failed (one line per failure on stderr).

set -eu

here=$(cd "$(dirname "$0")" && pwd)
script=$here/lint_ticket.sh
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT

failures=0
count=0
out=
code=0

# A spec with two tasks: T-01 cites FR-01, FR-02 and C-01 (no NFR); T-02 cites FR-03, FR-05,
# NFR-01 and D-01 and depends on T-01. AC-02 cites FR-01 and FR-05, so it is in both slices.
write_spec() {
  cat > "$1" <<'EOF'
# Spec: Demo

Status: ready
Intent-slug: demo
Language: en-US
Last updated: 2026-10-14
Context sources: none

## 1. Goal and context
- Show the slicing. (Source: Q1)

## 2. Non-goals
- Do not publish the spec. (Source: Q2)

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client sends request 101 THE SYSTEM SHALL respond with HTTP 429.
- FR-02 (Source: Q3): WHEN a request is rejected THE SYSTEM SHALL include a Retry-After header.
- FR-03 (Source: Q4): WHEN the limiter is disabled THE SYSTEM SHALL pass all requests.
- FR-05 (Source: Q4): WHEN the limit resets THE SYSTEM SHALL accept requests again.

## 4. Non-functional requirements
- NFR-01 (Source: Q5): Added latency p95 below 5 ms.

## 5. Acceptance criteria
- AC-01 (FR-01, FR-02, Source: Q6): Given 100 requests When request 101 arrives Then the status is 429.
- AC-02 (FR-01, FR-05, Source: Q6): Given a blocked client When the minute ends Then request 102 passes.
- AC-03 (FR-03, Source: Q6): Given the limiter is off When 200 requests arrive Then none is rejected.

## 6. Technical constraints
- C-01 (Source: Q7): Node 20 and vitest.

## 7. Design
- D-01 (Source: Q8): Middleware in src/middleware/rate-limit.js.

## 8. Task plan
- T-01 (FR-01, FR-02, C-01, Source: Q9): Reject request 101 | Depends on: - | DoD: AC-01 and AC-02 pass.
- T-02 (FR-03, FR-05, NFR-01, D-01, Source: Q9): Add the off switch | Depends on: T-01 | DoD: AC-03 passes.

## 9. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-01 | `npx vitest run a` | exit code 0 | Q10 |
| AC-02 | `npx vitest run b` | exit code 0 | Q10 |
| AC-03 | `npx vitest run c` | exit code 0 | Q10 |

## 10. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Ask first
- Adding a dependency. (Source: Q11)
### Never
- Edit test files. (Source: Q11)
### Open questions
- Should FR-01 count retries? (Source: Q12)
- Should FR-03 log a warning? (Source: Q12)
- None of the others. (Source: Q12)

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Show it | A |
| Q2 | 1 | Non-goals | No publishing | A |
| Q3 | 2 | FR-01 and FR-02 | Confirmed | A |
| Q4 | 2 | FR-03 and FR-05 | Confirmed | A |
| Q5 | 3 | Latency | p95 below 5 ms | A |
| Q6 | 2 | Acceptance criteria | Confirmed | A |
| Q7 | 3 | Stack | Node 20 | A |
| Q8 | 4 | Design | Middleware | A |
| Q9 | 6 | Tasks | Two tasks | A |
| Q10 | 6 | Commands | Confirmed | A |
| Q11 | 5 | Boundaries | Confirmed | A |
| Q12 | 5 | Open questions | Kept | A |
EOF
}

# The ticket for the slice T-01: no NFR, so section 4 holds only the marker. The Spec line
# carries the placeholder @HASH@. The open question that cites FR-01 is in; the one that
# cites FR-03 is out; the one that cites no ID is out.
write_ticket_t01() {
  cat > "$1" <<'EOF'
- **Spec**: .piv/demo/spec.md @ @HASH@
- **Slice**: T-01
- **Type**: feature
- **Blocked by**: none
- **Size**: S
- **Intent-slug**: demo
- **Language**: en-US

## 1. Goal and context
- Show the slicing. (Source: Q1)

## 2. Non-goals
- Do not publish the spec. (Source: Q2)

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client sends request 101 THE SYSTEM SHALL respond with HTTP 429.
- FR-02 (Source: Q3): WHEN a request is rejected THE SYSTEM SHALL include a Retry-After header.

## 4. Non-functional requirements
None in this ticket.

## 5. Acceptance criteria
- AC-01 (FR-01, FR-02, Source: Q6): Given 100 requests When request 101 arrives Then the status is 429.
- AC-02 (FR-01, FR-05, Source: Q6): Given a blocked client When the minute ends Then request 102 passes.

## 6. Technical constraints
- C-01 (Source: Q7): Node 20 and vitest.

## 7. Design
None in this ticket.

## 8. Task plan
- T-01 (FR-01, FR-02, C-01, Source: Q9): Reject request 101 | Depends on: - | DoD: AC-01 and AC-02 pass.

## 9. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-01 | `npx vitest run a` | exit code 0 | Q10 |
| AC-02 | `npx vitest run b` | exit code 0 | Q10 |

## 10. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Ask first
- Adding a dependency. (Source: Q11)
### Never
- Edit test files. (Source: Q11)
### Open questions
- Should FR-01 count retries? (Source: Q12)

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Show it | A |
| Q2 | 1 | Non-goals | No publishing | A |
| Q3 | 2 | FR-01 and FR-02 | Confirmed | A |
| Q6 | 2 | Acceptance criteria | Confirmed | A |
| Q7 | 3 | Stack | Node 20 | A |
| Q9 | 6 | Tasks | Two tasks | A |
| Q10 | 6 | Commands | Confirmed | A |
| Q11 | 5 | Boundaries | Confirmed | A |
| Q12 | 5 | Open questions | Kept | A |
EOF
}

# The ticket for the slice T-02, blocked by T-01. AC-03 only, and
# AC-02 too, because its head cites FR-05. The line of T-01 is not copied.
write_ticket_t02() {
  cat > "$1" <<'EOF'
- **Spec**: .piv/demo/spec.md @ @HASH@
- **Slice**: T-02
- **Type**: feature
- **Blocked by**: T-01
- **Size**: S
- **Intent-slug**: demo
- **Language**: en-US

## 1. Goal and context
- Show the slicing. (Source: Q1)

## 2. Non-goals
- Do not publish the spec. (Source: Q2)

## 3. Functional requirements
- FR-03 (Source: Q4): WHEN the limiter is disabled THE SYSTEM SHALL pass all requests.
- FR-05 (Source: Q4): WHEN the limit resets THE SYSTEM SHALL accept requests again.

## 4. Non-functional requirements
- NFR-01 (Source: Q5): Added latency p95 below 5 ms.

## 5. Acceptance criteria
- AC-02 (FR-01, FR-05, Source: Q6): Given a blocked client When the minute ends Then request 102 passes.
- AC-03 (FR-03, Source: Q6): Given the limiter is off When 200 requests arrive Then none is rejected.

## 6. Technical constraints
None in this ticket.

## 7. Design
- D-01 (Source: Q8): Middleware in src/middleware/rate-limit.js.

## 8. Task plan
- T-02 (FR-03, FR-05, NFR-01, D-01, Source: Q9): Add the off switch | Depends on: T-01 | DoD: AC-03 passes.

## 9. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-02 | `npx vitest run b` | exit code 0 | Q10 |
| AC-03 | `npx vitest run c` | exit code 0 | Q10 |

## 10. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Ask first
- Adding a dependency. (Source: Q11)
### Never
- Edit test files. (Source: Q11)
### Open questions
- Should FR-03 log a warning? (Source: Q12)

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Show it | A |
| Q2 | 1 | Non-goals | No publishing | A |
| Q4 | 2 | FR-03 and FR-05 | Confirmed | A |
| Q5 | 3 | Latency | p95 below 5 ms | A |
| Q6 | 2 | Acceptance criteria | Confirmed | A |
| Q8 | 4 | Design | Middleware | A |
| Q9 | 6 | Tasks | Two tasks | A |
| Q10 | 6 | Commands | Confirmed | A |
| Q11 | 5 | Boundaries | Confirmed | A |
| Q12 | 5 | Open questions | Kept | A |
EOF
}

# new_case [name] [t01|t02]: a directory holding the spec at .piv/demo/spec.md and
# a ticket.md cut from it, with the real revision hash filled in; entered.
new_case() {
  mkdir -p "$root/$1/.piv/demo"
  cd "$root/$1"
  git init -q -b main
  write_spec .piv/demo/spec.md
  "write_ticket_$2" ticket.md
  hash=$(git hash-object --no-filters .piv/demo/spec.md)
  sed -i "s/@HASH@/$hash/" ticket.md
}

# run: runs the script on ticket.md and the spec; sets $out and $code. The script is
# committed without the executable bit, so it runs through sh, never as a program.
run() {
  code=0
  out=$(sh "$script" ticket.md .piv/demo/spec.md 2>&1) || code=$?
}

# pass [case]: the ticket is accepted.
pass() {
  count=$((count + 1))
  run
  if [ "$code" -ne 0 ] || [ "$out" != "RESULT: OK" ]; then
    echo "FAIL: $1: expected exit 0 and RESULT: OK, got exit $code: $out" >&2
    failures=$((failures + 1))
  fi
}

# reject [case] [text]: exit 1, the output holds [text] and ends with the result line.
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

# check [case] [command...]: the command succeeds in the case directory.
check() {
  local name=$1
  shift
  count=$((count + 1))
  if ! "$@" > /dev/null 2>&1; then
    echo "FAIL: $name" >&2
    failures=$((failures + 1))
  fi
}

# line_of [text]: the line number of the first ticket.md line holding the text.
line_of() {
  grep -n -F -- "$1" ticket.md | head -n 1 | cut -d: -f1
}

# AC-05: the header names the spec path and hash, the slice, the blockers, the size, the slug
# and the language, and every bullet of sections 1 to 10 is a line of the spec.
new_case t01-valid t01
pass "AC-05: a ticket cut verbatim from the spec"
check "AC-05: the header carries the spec path and hash" grep -qE '^- \*\*Spec\*\*: \.piv/demo/spec\.md @ [0-9a-f]{40}$' ticket.md
check "AC-05: the header carries the slice, type, blockers, size, slug and language" \
  sh -c 'grep -q "^- \*\*Slice\*\*: T-01$" ticket.md && grep -q "^- \*\*Type\*\*: feature$" ticket.md && grep -q "^- \*\*Blocked by\*\*: none$" ticket.md && grep -q "^- \*\*Size\*\*: S$" ticket.md && grep -q "^- \*\*Intent-slug\*\*: demo$" ticket.md && grep -q "^- \*\*Language\*\*: en-US$" ticket.md'

# AC-06: the slice T-01 cites FR-01 and FR-02; the AC whose head cites FR-01 and FR-05 comes whole.
check "AC-06: section 3 holds FR-01 and FR-02" sh -c 'grep -q "^- FR-01 " ticket.md && grep -q "^- FR-02 " ticket.md'
check "AC-06: section 3 holds no FR-03" sh -c '! grep -q "^- FR-03 " ticket.md'
check "AC-06: section 5 holds the AC headed (FR-01, FR-05)" grep -q '^- AC-02 (FR-01, FR-05, Source: Q6):' ticket.md

# AC-07: a slice that cites no NFR has only the marker in section 4.
check "AC-07: section 4 holds only the marker" \
  sh -c 'awk "/^## 4\./{f=1;next} /^## /{f=0} f&&NF" ticket.md | grep -qx "None in this ticket."; test "$(awk "/^## 4\./{f=1;next} /^## /{f=0} f&&NF" ticket.md | wc -l)" -eq 1'

new_case t02-valid t02
pass "AC-05: the ticket of a task that depends on another ticket"
check "D-05: the blocker is T-01 and the task keeps Depends on: T-01" \
  sh -c 'grep -q "^- \*\*Blocked by\*\*: T-01$" ticket.md && grep -q "Depends on: T-01 |" ticket.md && ! grep -q "^- T-01 " ticket.md'

# AC-08: a line changed against the spec is named by its number, with exit 1.
new_case changed-line t01
n=$(line_of "FR-02")
sed -i "${n}s/Retry-After/Retry-Before/" ticket.md
reject "AC-08: a changed line" "FAIL line $n: not a verbatim line of the spec"

# Mutants of a valid ticket, each of which must be rejected.
new_case id-removed t01
sed -i 's/^- FR-02 (Source: Q3)/- (Source: Q3)/' ticket.md
reject "mutant: an ID removed from a line" "not a verbatim line of the spec"

new_case id-line-dropped t01
sed -i '/^- FR-02 /d' ticket.md
reject "mutant: a cited ID whose line is dropped" "is missing the spec line"

new_case marker-wrong t01
n=$(line_of "None in this ticket.")
sed -i "${n}s/.*/None here./" ticket.md
reject "mutant: a wrong marker" "not a verbatim line of the spec"

new_case marker-with-content t01
n=$(line_of "None in this ticket.")
sed -i "${n}a - NFR-01 (Source: Q5): Added latency p95 below 5 ms." ticket.md
reject "mutant: the marker beside content" "does not pull in this line of the spec"

new_case marker-missing t01
n=$(line_of "None in this ticket.")
sed -i "${n}d" ticket.md
reject "mutant: an empty section with no marker" "write None in this ticket."

new_case marker-in-full-section t01
n=$(line_of "- Show the slicing.")
sed -i "${n}a None in this ticket." ticket.md
reject "mutant: the marker in a section with content" "is used in section 1"

new_case extra-fr t01
n=$(line_of "- FR-02 ")
sed -i "${n}a - FR-03 (Source: Q4): WHEN the limiter is disabled THE SYSTEM SHALL pass all requests." ticket.md
reject "mutant: an FR no task of the slice cites" "the slice does not pull in this line of the spec"

new_case extra-open-question t01
n=$(line_of "- Should FR-01")
sed -i "${n}a - Should FR-03 log a warning? (Source: Q12)" ticket.md
reject "mutant: an open question that cites no ID of the slice" "the slice does not pull in this line of the spec"

new_case open-question-dropped t01
sed -i '/^- Should FR-01/d' ticket.md
reject "mutant: an open question of the slice dropped" "is missing the spec line"

new_case ac-dropped t01
sed -i '/^- AC-02 /d' ticket.md
reject "mutant: an AC of the slice dropped" "is missing the spec line"

new_case ac-row-dropped t01
sed -i '/^| AC-02 /d' ticket.md
reject "mutant: the section 9 row of an AC dropped" "is missing the spec line"

new_case q-row-dropped t01
sed -i '/^| Q7 /d' ticket.md
reject "mutant: the decision-log row of a cited Q dropped" "is missing the spec line"

new_case q-row-extra t01
sed -i '/^| Q12 /a | Q5 | 3 | Latency | p95 below 5 ms | A |' ticket.md
reject "mutant: a decision-log row no line cites" "the slice does not pull in this line of the spec"

new_case copied-twice t01
n=$(line_of "- Show the slicing.")
sed -i "${n}a - Show the slicing. (Source: Q1)" ticket.md
reject "mutant: a line copied twice" "line is copied twice"

new_case out-of-order t01
a=$(line_of "- FR-01 ")
sed -i "${a}{h;d};/^- FR-02 /{G}" ticket.md
reject "mutant: lines out of the spec order" "out of the spec order"

new_case heading-changed t01
sed -i 's/^## 3. Functional requirements/## 3. Requirements/' ticket.md
reject "mutant: a changed heading" "heading is not a heading of the spec"

new_case heading-dropped t01
sed -i '/^## 7. Design/,+1d' ticket.md
reject "mutant: a dropped section" "the ticket has no"

new_case placeholder t01
sed -i 's/^- Show the slicing\./- [PENDING]/' ticket.md
reject "mutant: a [PENDING] marker" "unresolved [PENDING] marker"

# The header block.
new_case hash-wrong t01
sed -i 's/ @ [0-9a-f]*$/ @ 0000000000000000000000000000000000000000/' ticket.md
reject "header: a hash that is not the spec revision" "is not the spec revision"

new_case hash-after-edit t01
echo "- Added later. (Source: Q1)" >> .piv/demo/spec.md
reject "header: the spec changed after the ticket was cut" "is not the spec revision"

new_case spec-no-hash t01
sed -i 's/ @ [0-9a-f]*$//' ticket.md
reject "header: a Spec field with no hash" "Spec must read"

new_case label-missing t01
sed -i '/^- \*\*Size\*\*/d' ticket.md
reject "header: a missing label" 'header is missing "Size"'

new_case label-unknown t01
sed -i 's/^- \*\*Size\*\*: S/- **Estimate**: S/' ticket.md
reject "header: an unknown label" 'unknown header label "Estimate"'

new_case slug-wrong t01
sed -i 's/^- \*\*Intent-slug\*\*: demo/- **Intent-slug**: other/' ticket.md
reject "header: a slug that is not the spec's" "Intent-slug is not the spec Intent-slug"

new_case language-wrong t01
sed -i 's/^- \*\*Language\*\*: en-US/- **Language**: pt-BR/' ticket.md
reject "header: a language that is not the spec's" "Language is not the spec Language"

new_case slice-unknown t01
sed -i 's/^- \*\*Slice\*\*: T-01/- **Slice**: T-09/' ticket.md
reject "header: a slice that is not a task of the spec" "is not a task of the spec"

new_case blocked-bad t01
sed -i 's/^- \*\*Blocked by\*\*: none/- **Blocked by**: T-01 T-02/' ticket.md
reject "header: a malformed Blocked by" "Blocked by must be"

new_case blocked-none-with-dependency t02
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: none/' ticket.md
reject "header: Blocked by none for a task that depends on another ticket" "Blocked by cannot be none"

new_case part-of t01
sed -i '1i - **Part of**: #10' ticket.md
reject "header: a Part of line, which a ticket no longer carries" 'unknown header label "Part of"'

new_case type-missing t01
sed -i '/^- \*\*Type\*\*/d' ticket.md
reject "header: a missing Type" 'header is missing "Type"'

new_case type-bad t01
sed -i 's/^- \*\*Type\*\*: feature/- **Type**: epic/' ticket.md
reject "header: a Type outside bug, feature and task" "Type must be bug, feature or task"

new_case slice-two-tasks t01
sed -i 's/^- \*\*Slice\*\*: T-01/- **Slice**: T-01, T-02/' ticket.md
reject "header: a slice of two tasks" "a ticket carries exactly one task"

new_case title-line t01
sed -i '1i # A title' ticket.md
reject "header: a title line in the body" 'header line is not "- **Label**: value"'

new_case size-bad t01
sed -i 's/^- \*\*Size\*\*: S/- **Size**: banana/' ticket.md
reject "header: a size outside S, M and L" "Size must be S, M or L"

new_case spec-path-wrong t01
sed -i 's| .piv/demo/spec.md @ | /nonexistent/other.md @ |' ticket.md
reject "header: a Spec path that is not the spec" "is not the spec"

new_case slice-twice t01
sed -i 's/^- \*\*Slice\*\*: T-01/- **Slice**: T-01, T-01/' ticket.md
reject "header: a task named twice in the slice" "is named twice"

new_case crlf-ticket t01
awk '{printf "%s%c\n", $0, 13}' ticket.md > ticket.crlf && mv ticket.crlf ticket.md
reject "mutant: a ticket whose lines end in CR" "FAIL line"

new_case blocked-invented t01
sed -i 's/^- \*\*Blocked by\*\*: none/- **Blocked by**: T-05, T-06/' ticket.md
reject "header: Blocked by on a slice that depends on no outside task" "so Blocked by must be none"

new_case blocked-extra t02
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: T-01, T-03/' ticket.md
reject "header: a blocker no task of the slice depends on" "T-03 is in Blocked by, but no task of the slice depends on it"

new_case blocked-wrong t02
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: T-03/' ticket.md
reject "header: a dependency Blocked by leaves out" "the slice depends on T-01, which Blocked by does not name"

new_case blocked-ticket-id t02
sed -i 's/^- \*\*Blocked by\*\*: T-01/- **Blocked by**: #12/' ticket.md
reject "header: a ticket id instead of a task id in Blocked by" "Blocked by must be"

# Usage and I/O errors exit 2.
new_case usage t01
for args in "" "ticket.md" "ticket.md .piv/demo/spec.md extra" "missing.md .piv/demo/spec.md" "ticket.md missing.md"; do
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
