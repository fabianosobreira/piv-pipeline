---
name: piv-spec
description: Interviews the user in fixed phases until both sides confirm shared understanding, then writes one 10-section spec that piv-slice cuts into tickets. Takes an optional PRD as context.
argument-hint: "[intent-slug] · [optional: PRD path] (blank = starts by asking for them)"
disable-model-invocation: true
allowed-tools: Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh *)
---

# Spec: the interview that fixes the plan

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. It writes `docs/.plans/[intent-slug].spec.md`: the one plan `piv-slice` cuts into tickets. A PRD from `piv-write-prd` is optional context; this skill is the only one that reads it.

- Output skeleton: [templates/spec.md](templates/spec.md)
- Validator: `${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh` (execute it, do not read it). It needs only POSIX `sh` and `awk`.

Done when the lint prints `RESULT: OK`, the user confirmed the full playback, and the file says `Status: ready`.

## Language

- Talk to the user, and write spec content, in the intent's language: the PRD's `Language` when a PRD is given, otherwise the language the user runs this interview in. Record it in the spec's `Language` field as a BCP 47 tag, such as `pt-BR`.
- Keep these in English because the validator depends on them: section headings, header labels, IDs (`FR-01`, `NFR-01`, `C-01`, `D-01`, `AC-01`, `T-01`, `Q1`), keywords (`WHEN`, `THE SYSTEM SHALL`, `Given`/`When`/`Then`, `Source:`, `Depends on:`, `DoD:`), `Status:` values, and markers (`[PENDING]`, `[DEFERRED]`).

## Rules

1. **The agent never fills a gap.** Every spec statement comes from an explicit user answer or an option the user chose. A fact read from context, a PRD included, enters the spec only after the user confirms it in a question.
2. **Options are proposals, not content.** An option becomes content only when the user picks it.
3. **A recommendation requires an observable fact with a source** (`path:line`, document section, or command output). Preference, best practice, and popularity are not facts.
4. **Conflict between an answer and the context is never resolved silently.** Show the fact and its source, then ask again.
5. **No vague terms.** "Fast", "adequate", "user-friendly", "robust", "scalable" need a measurable value or a verification command from the user.
6. **A verification command enters the spec only if it exists in the repo** (scripts, `Makefile`, CI) **or the user provided it.**
7. **Delegation is declined.** To "you decide", re-ask with the recommended option (only if a fact supports one) and require explicit confirmation.

## Running commands

Commands produce observable facts (current coverage, last commits, tool versions).

- Run without asking: read-only commands that change no tracked file and install nothing (`git log`, `git status`, `git ls-files`, `--version`) and the test, coverage, lint, and typecheck commands the repo already defines.
- Ask first: installs, network access, writes outside ignored paths, or commands expected to run long.
- Cite as source the command and the relevant output: `pytest --cov → 71%`.
- Report a failing command as a fact. Do not work around it silently.

## Question format

At most 3 questions per message. Number questions globally and continuously (`Q1`, `Q2`, ...). Give 1 to 3 options per question (1 option = confirmation question). Every message of questions ends on a **GATE**.

```markdown
🔍 **Q7 - Coverage threshold**: Which minimum line coverage must the change meet?

- A - 80% total, matching CI
- B - 90% on changed files only
- C - No threshold; acceptance tests only

> 💡 Recommend A. Evidence: `.github/workflows/ci.yml:24` runs `pytest --cov-fail-under=80`. Justification: A matches the gate CI already enforces; B or C would add a second, different gate.

```

No fact decides between the options:

```markdown
> 💡 No recommendation: no observable fact in the context decides between the options.
```

No context to propose options: ask an open question, with no list and no 💡.

| User reply | Handling |
|---|---|
| `A`, `B`, `C` | Record the chosen option |
| `A with change: ...` | Record the option with the change |
| Free text | Record literally; restate it in the phase playback |
| `?` or `defer` | Add to section 10 as an open question marked `[DEFERRED]` |
| "You decide" | Rule 7 |

## Workflow

Copy this checklist into the first message and update it at the end of each phase:

```
Interview Progress:
- [ ] Phase 0: Recon
- [ ] Phase 1: Goal and scope (sections 1, 2)
- [ ] Phase 2: Behavior (sections 3, 5)
- [ ] Phase 3: Quality and technical limits (sections 4, 6)
- [ ] Phase 4: Design (section 7)
- [ ] Phase 5: Boundaries (section 10)
- [ ] Phase 6: Execution and verification (sections 8, 9)
- [ ] Phase 7: Synthesis
```

Run phases in order. A phase closes only when all of these hold:

- **Playback**: the agent restated the phase in its own words and the user confirmed or corrected it.
- **No gaps**: every statement written in the phase has a `Source: Q<n>`.
- **Example test** (phases 2 and 4): concrete cases were validated.
- **No loose ends**: every doubt is answered or marked `[DEFERRED]`.

After closing a phase, write it to the output file and add one row per question to the decision log. If the output file already exists with `[PENDING]` sections, resume at the first phase that still has them.

### Phase 0 - Recon

1. Read before asking: the PRD when `$ARGUMENTS` carries one (end to end), `README`, `CLAUDE.md`/`AGENTS.md`, manifests (`package.json`, `pyproject.toml`, `go.mod`), directory tree, existing tests, CI config, `docs/`, and any analysis document the user points to. Run the commands that give facts needed later (see Running commands).
2. Present a short inventory: sources read, commands run, relevant sources missing.
3. Ask, in one message: additional sources, and the intent slug when it is not settled. The slug is the PRD's `Intent-slug` when a PRD is given, and `$ARGUMENTS` when it carries one; otherwise propose one as `docs/issue-tracker.md` defines the `intent-slug`. **GATE.**

As soon as the slug is settled, create `docs/.plans/[intent-slug].spec.md` from [templates/spec.md](templates/spec.md), used exactly: set `Intent-slug` and `Language`, and list every source read, the PRD included, under `Context sources`.

With a PRD, use its sections as sources of questions, never of content: its MVP and success metrics suggest behaviors, its non-goals suggest section 2, its constraints suggest section 6, and its open questions, `Architecture: [decision]` ones included, suggest the questions of phases 3 and 4 and the open questions of section 10.

### Phase 1 - Goal and scope (sections 1, 2)

Ask: the problem and expected outcome, the affected user or system, and non-goals. Propose non-goal candidates as options when the context suggests them (for example, an item discarded in the analysis document).

### Phase 2 - Behavior (sections 3, 5)

1. Collect each behavior from the user. Restate it in EARS form (`WHEN [event] THE SYSTEM SHALL [response]`) using only elements the user gave. Assign IDs (`FR-01`, ...) and ask for confirmation.
2. For each `FR-xx`, derive acceptance criteria in Given/When/Then. Expected values come from the user.
3. **Example test**: for each requirement, present 2-3 concrete cases (one an edge case) and ask the expected result of each. A divergence from the draft means the requirement is revised.

### Phase 3 - Quality and technical limits (sections 4, 6)

- Section 4: ask for numeric values (p95 latency, coverage, memory limits, security requirements, compatibility). Values found in config or CI may be proposed as options, with source. Number each item `NFR-01`, ...
- Section 6: stack and versions (propose those found in manifests), code conventions, files and directories that may or may not change, allowed dependencies. Number each item `C-01`, ...

### Phase 4 - Design (section 7)

Ask about API contracts, schemas, data model, interfaces, and sequence diagrams. Proposed options mirror patterns already in the code (cite the file). A new contract with no observable pattern is an open question. Number each item `D-01`, ...

### Phase 5 - Boundaries (section 10)

Ask for the three levels: **Always** (the agent acts without asking), **Ask first** (the agent pauses and asks), **Never** (forbidden). Propose options from sensitive areas observed in the repo (migrations, CI files, secrets, `tests/`, lockfiles). Close the section with the open questions accumulated so far. If there are none, record `None.` with the `Source:` of the question that confirmed it.

### Phase 6 - Execution and verification (sections 8, 9)

1. Section 8: propose task granularity (options A/B with task counts). Each task cites its `FR-xx` and every `NFR-xx`, `C-xx` and `D-xx` that shapes it, lists dependencies, and states a definition of done (`DoD:`). Every `NFR`, `C` and `D` is cited by at least one task, because `piv-slice` copies into a ticket only the items its tasks cite. Target size: one PR per task. The user confirms order and scope.
2. Section 9: one row per acceptance criterion with the exact verification command, a pass criterion (for example, exit code 0), and the origin of the command (`Q<n>` or `path:line`), following rule 6.

### Phase 7 - Synthesis

1. Run `sh ${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh [spec-file]`.
2. If it prints findings, go back to the phase of the affected section, ask the question that closes the finding, update the file and decision log, and run the lint again. Repeat until it prints `RESULT: OK`.
3. Give a full playback: a section-by-section summary in the user's words, with confirmation questions.
4. Set `Status: ready` only when the lint prints `RESULT: OK` and the user confirms explicitly. Otherwise keep `Status: draft` and list the blockers.

The lint checks structure and traceability. It does not check meaning: playback, example tests, and vague terms outside its word list stay manual.

## Output file rules

- Write the spec in the intent's language, as the Language section says; headings, labels, IDs and keywords stay as the template writes them.
- Write every statement as a top-level `- ` bullet ending with `(Source: Q<n>)`. Multiple sources: `(Source: Q3, Q5)`.
- One statement per line: `piv-slice` copies lines verbatim into tickets.
- Requirement: `- FR-01 (Source: Q3): WHEN ... THE SYSTEM SHALL ...`
- Non-functional requirement, constraint, design item: `- NFR-01 (Source: Q11): ...`, `- C-01 (Source: Q12): ...`, `- D-01 (Source: Q14): ...`
- Acceptance criterion: `- AC-01 (FR-01, Source: Q4): Given ... When ... Then ...`
- Task: `- T-01 (FR-01, NFR-01, C-02, D-01, Source: Q9): ... | Depends on: - | DoD: ...`
- Section 9 rows: `| AC-01 | `command` | pass criterion | Q12 |`. A `|` character is not allowed inside a cell; put pipelines in a script file and reference the script.
- Every `Q<n>` cited must have a row in the decision log.
- `Status:` is `draft` or `ready`.

## Hand off

Confirm where the spec landed, by path, then offer the next move and let the user run it:

- **Slice it** — run `piv-slice [spec path]`, here or in a fresh session.

## Effort limits

- At most 5 questions per phase by default. Beyond that, tell the user and ask whether to continue.
- A question whose answer is unambiguous in the context becomes a 1-option confirmation, not an open question.
- A phase with enough context may be compressed into one confirmation message. It is never skipped.
