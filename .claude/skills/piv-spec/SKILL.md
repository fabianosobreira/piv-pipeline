---
name: piv-spec
description: "Interviews the user in fixed phases, then writes one 10-section spec for piv-review-spec to audit. Takes a concept: free text, or documents with their links."
argument-hint: "[intent-slug] · [concept: text, file path or URLs] (blank = starts by asking for them)"
disable-model-invocation: true
allowed-tools: Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh *), WebFetch
---

# Spec: the interview that fixes the plan

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. It writes `.piv/[intent-slug]/spec.md`: the one plan `piv-review-spec` audits and `piv-slice` cuts into tickets. The input is a concept in free text or reference documents, a PRD among them like any other.

- Output skeleton: `${CLAUDE_SKILL_DIR}/templates/spec.md`
- Validator: `${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh` (execute it, do not read it). It needs only POSIX `sh` and `awk`.

## Success criteria

**The interview:**

- ✅ Every spec statement traces to a `Q<n>` the user answered, with a decision log row; the agent filled no gap (rules 1, 2).
- ✅ Every 💡 carries an `Empirical:` basis with its source, a `Pragmatic:` basis naming the problem it solves, or both; a claim that could be checked without asking was checked first, and `unverified` appears only where the user declined the check (rule 3).
- ✅ Every conflict between an answer and the context was shown with its source and asked again (rule 4).
- ✅ Every "you decide" was declined and re-asked (rule 7).

**The spec:**

- ✅ No vague term stands without a measurable value or a verification command (rule 5).
- ✅ Every section 10 command exists in the repo or came from the user (rule 6).
- ✅ The lint printed `RESULT: OK` and the file says `Status: ready` — or it says `Status: draft` and the blockers are listed.

## Language

- Talk to the user, and write spec content, in the intent's language: the one the user runs the first interview in. Record it in the spec's `Language` field as a BCP 47 tag, such as `pt-BR`.
- Keep these in English because the validator depends on them: section headings, header labels, IDs (`FR-01`, `NFR-01`, `C-01`, `D-01`, `AC-01`, `T-01`, `Q1`), keywords (`WHEN`, `THE SYSTEM SHALL`, `Given`/`When`/`Then`, `Source:`, `Depends on:`, `DoD:`), `Status:` values, and markers (`[PENDING]`, `[DEFERRED]`).

## Rules

1. **The agent never fills a gap.** Every spec statement comes from an explicit user answer or an option the user chose. A fact read from a source enters the spec only after the user confirms it in a question.
2. **Options are proposals, not content.** An option becomes content only when the user picks it.
3. **A recommendation requires an empirical or a pragmatic basis, or both.** Empirical: a claim that can be checked, with its source (`path:line`, document section, command output, or a doc URL). Before recommending, run the check that settles the claim when Running commands lets it run without asking, and cite its output as the source. When the check needs asking first, ask before recommending; if the user declines, the claim carries `(unverified — check: [command, test or doc])`. Pragmatic: names the concrete problem in the spec or project (`FR-xx`, `C-xx`, `Q<n>`, `path:line`) and states how the option solves it. Preference, popularity, and authority not tied to a concrete problem are no basis. Numeric values follow the same rule.
4. **Conflict between an answer and the context is never resolved silently.** Show the fact and its source, then ask again.
5. **No vague terms.** "Fast", "adequate", "user-friendly", "robust", "scalable" need a measurable value or a verification command from the user.
6. **A verification command enters the spec only if it exists in the repo** (scripts, `Makefile`, CI) **or the user provided it.**
7. **Delegation is declined.** To "you decide", re-ask with the recommended option (only if an empirical or pragmatic basis supports one) and require explicit confirmation.

## Running commands

Commands, doc lookups and probe programs produce observable facts (current coverage, last commits, tool versions, what a library actually does).

- Run without asking:
  - read-only commands that change no tracked file and install nothing (`git log`, `git status`, `git ls-files`, `--version`) and the test, coverage, lint, and typecheck commands the repo already defines;
  - fetching a library's or tool's official documentation from the web;
  - reading, with `WebFetch`, every URL the user passed in the concept — cite each one as a source;
  - a probe: a small throwaway program that tests a claim, written to a temporary directory outside the repo, using only dependencies already installed, and deleted after it runs.
- Ask first: installs, other network access — a link you found inside a source included — or commands expected to run long.
- Cite as source the command and the relevant output: `pytest --cov → 71%`. For a doc, cite its URL; for a probe, show its code and output.
- Report a failing command as a fact. Do not work around it silently.

## Question format

At most 3 questions per message. Number questions globally and continuously (`Q1`, `Q2`, ...). Give 1 to 3 options per question (1 option = confirmation question). Every message of questions ends on a **GATE**.

```markdown
🔍 **Q7 - Coverage threshold**: Which minimum line coverage must the change meet?

- A - 80% total, matching CI
- B - 90% on changed files only
- C - No threshold; acceptance tests only

> 💡 Recommend A. Empirical: `.github/workflows/ci.yml:24` runs `pytest --cov-fail-under=80`. Pragmatic: A reuses the gate CI already enforces; B or C would add a second, different gate.
```

A recommendation may carry only one label; omit the absent one:

```markdown
> 💡 Recommend B. Pragmatic: FR-02 needs per-client limits across instances; a shared store solves it, an in-memory counter does not.
```

A claim stays unverified only when the user declined its check (rule 3):

```markdown
> 💡 Recommend B. Empirical: `rate-limiter-flexible` supports a Redis store (unverified — check: its README, *Usage with Redis*). Pragmatic: FR-02 needs one counter shared across instances.
```

No basis decides between the options:

```markdown
> 💡 No recommendation: no empirical or pragmatic basis decides between the options.
```

No context to propose options: ask an open question, with no list and no 💡.

| User reply | Handling |
|---|---|
| `A`, `B`, `C` | Record the chosen option |
| `A with change: ...` | Record the option with the change |
| Free text | Record literally |
| `?` or `defer` | Add to section 8 as an open question marked `[DEFERRED]` |
| "You decide" | Rule 7 |

## Process

Copy this checklist into the first message. Tick a phase only when it closes: its **Done when** and the criteria below hold.

```
- [ ] Phase 0 — Recon
- [ ] Phase 1 — Goal and scope (sections 1, 2)
- [ ] Phase 2 — Behavior (sections 3, 4)
- [ ] Phase 3 — Quality and technical limits (sections 5, 6)
- [ ] Phase 4 — Design (section 7)
- [ ] Phase 5 — Boundaries (section 8)
- [ ] Phase 6 — Execution and verification (sections 9, 10)
- [ ] Phase 7 — Synthesis
```

Run phases in order. A phase closes only when its **Done when** and all of these hold:

- **No gaps**: every statement written in the phase has a `Source: Q<n>`. Header fields are not statements.
- **Example test** (phases 2 and 4): concrete cases were validated.
- **No loose ends**: every doubt is answered or marked `[DEFERRED]`.

After closing a phase, write it to the output file and add one row per question to the decision log. If the output file already exists with `[PENDING]` sections, resume at the first phase that still has them. A spec `piv-review-spec` reopened reads `Status: draft`, and its `spec.review.md` names the items to settle: resume at the phase of each one.

### Phase 0 — Recon

1. Read before asking: the concept `$ARGUMENTS` carries — a paragraph, a file, or a full document with links — with every URL the user passed in it; `README`, `CLAUDE.md`/`AGENTS.md`, manifests (`package.json`, `pyproject.toml`, `go.mod`), directory tree, existing tests, CI config, `docs/`, and any analysis document the user points to. Run the commands that give facts needed later (see Running commands).
2. Present a short inventory: sources read, commands run, relevant sources missing.
3. Ask, in one message: additional sources, and the intent slug when it is not settled. Propose the slug, derived from the concept as `docs/piv-loop.md` defines the `intent-slug`; when the input is a `.piv/[slug]/prd.md`, the slug is its folder's and the folder is reused. **GATE.**

As soon as the slug is settled, create `.piv/[intent-slug]/spec.md` from `${CLAUDE_SKILL_DIR}/templates/spec.md`, used exactly: set `Intent-slug` and `Language`, and list every source read under `Context sources`. Create the folder if it does not exist.

**Done when** the inventory was posted, the user answered the GATE, and the spec file exists with `Intent-slug`, `Language` and `Context sources` set.

### Phase 1 — Goal and scope (sections 1, 2)

Ask: the problem and expected outcome, the affected user or system, and non-goals. Propose non-goal candidates as options when the context suggests them (for example, an item discarded in the analysis document).

**Done when** sections 1 and 2 hold no `[PENDING]`.

### Phase 2 — Behavior (sections 3, 4)

1. Collect each behavior from the user. Restate it in EARS form (`WHEN [event] THE SYSTEM SHALL [response]`) using only elements the user gave. Assign IDs (`FR-01`, ...) and ask for confirmation.
2. For each `FR-xx`, derive acceptance criteria in Given/When/Then. Expected values come from the user.
3. **Example test**: for each requirement, present 2-3 concrete cases (one an edge case) and ask the expected result of each. A divergence from the draft means the requirement is revised.

**Done when** every `FR-xx` was confirmed in EARS form, has at least one `AC-xx`, and its example cases were answered.

### Phase 3 — Quality and technical limits (sections 5, 6)

- Section 5: ask for numeric values (p95 latency, coverage, memory limits, security requirements, compatibility). Values found in config or CI may be proposed as options, with source. Number each item `NFR-01`, ...
- Section 6: stack and versions (propose those found in manifests), code conventions, files and directories that may or may not change, allowed dependencies. A dependency absent from the manifests may be proposed under rule 3. Number each item `C-01`, ...

**Done when** every section 5 item is an `NFR-xx` with a measurable value, and sections 5 and 6 hold no `[PENDING]`.

### Phase 4 — Design (section 7)

Ask about API contracts, schemas, data model, interfaces, and sequence diagrams. List first the option that mirrors a pattern already in the code (cite the file), when one exists. A pattern, contract or external library absent from the code may be proposed under rule 3. Number each item `D-01`, ...

**Example test**: for each `D-xx` that defines a contract or schema, present 2-3 concrete instances (a request and its response, a record), one an edge case, and ask whether each is valid and what it yields. A divergence means the item is revised. An item with no contract, such as a sequence diagram, has no example test.

**Done when** every `D-xx` was confirmed, every one that defines a contract or schema had its example cases answered, and section 7 holds no `[PENDING]`.

### Phase 5 — Boundaries (section 8)

Ask for the three levels: **Always** (the agent acts without asking), **Ask first** (the agent pauses and asks), **Never** (forbidden). Propose options from sensitive areas observed in the repo (migrations, CI files, secrets, `tests/`, lockfiles). Close the section with the open questions accumulated so far. If there are none, record `None.` with the `Source:` of the question that confirmed it.

**Done when** *Always*, *Ask first*, *Never* and *Open questions* each hold a statement or `None.` with its `Source:`.

### Phase 6 — Execution and verification (sections 9, 10)

1. Section 9: propose task granularity (options A/B with task counts). Each task cites its `FR-xx` and every `NFR-xx`, `C-xx` and `D-xx` that shapes it, lists dependencies, and states a definition of done (`DoD:`). Every `NFR`, `C` and `D` is cited by at least one task, because `piv-slice` copies into a ticket only the items its tasks cite. Target size: one commit per task — each task is implemented, reviewed and committed on its own, so each one must be provable alone by its `DoD`. The user confirms order and scope.
2. Section 10: one row per acceptance criterion with the exact verification command, a pass criterion (for example, exit code 0), and the origin of the command (`Q<n>` or `path:line`), following rule 6.

**Done when** the user confirmed the task order and scope, every task carries its `FR`, `Depends on` and `DoD:`, every `NFR`, `C` and `D` is cited by a task, and every `AC-xx` has a section 9 row.

### Phase 7 — Synthesis

1. Run `sh ${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh [spec-file]`.
2. If it prints findings, go back to the phase of the affected section, ask the question that closes the finding, update the file and decision log, and run the lint again. Repeat until it prints `RESULT: OK`, or until the user defers or stops as step 4 says.
3. Walk the **Success criteria** at the top of this skill, line by line: the interview lines against this conversation, or against the decision log when the run resumed in a new session. A line that does not hold is a finding: handle it as in step 2.
4. Set `Status: ready` when the lint prints `RESULT: OK` and every Success criteria line holds. The run ends on `Status: draft`, with the blockers listed, only when the user answers `defer` to the question that would close a finding, or asks to stop the loop.

The lint checks structure and traceability. It does not check meaning: example tests and vague terms outside its word list stay manual.

**Done when** the lint printed `RESULT: OK` and the file says `Status: ready`, or it says `Status: draft` and the blockers are listed.

## Output file rules

- Write the spec in the intent's language, as the Language section says; headings, labels, IDs and keywords stay as the template writes them.
- Write every statement as a top-level `- ` bullet ending with `(Source: Q<n>)`. Multiple sources: `(Source: Q3, Q5)`.
- One statement per line: `piv-slice` copies lines verbatim into tickets.
- Requirement: `- FR-01 (Source: Q3): WHEN ... THE SYSTEM SHALL ...`
- Non-functional requirement, constraint, design item: `- NFR-01 (Source: Q11): ...`, `- C-01 (Source: Q12): ...`, `- D-01 (Source: Q14): ...`
- Acceptance criterion: `- AC-01 (FR-01, Source: Q4): Given ... When ... Then ...`
- Task: `- T-01 (FR-01, NFR-01, C-02, D-01, Source: Q9): ... | Depends on: - | DoD: ...`
- Section 10 rows: `| AC-01 | `command` | pass criterion | Q12 |`. A `|` character is not allowed inside a cell; put pipelines in a script file and reference the script.
- Every `Q<n>` cited must have a row in the decision log.
- `Status:` is `draft` or `ready`. Only `piv-review-spec` sets `reviewed`.

## Hand off

Confirm where the spec landed, by path, then offer the next move and let the user run it:

- **Review it** — run `piv-review-spec [intent-slug]`, in a session of its own.

## Effort limits

- At most 5 questions per phase by default. Beyond that, tell the user and ask whether to continue.
- A question whose answer is unambiguous in the context becomes a 1-option confirmation, not an open question.
- A phase with enough context may be compressed into one confirmation message. It is never skipped.
