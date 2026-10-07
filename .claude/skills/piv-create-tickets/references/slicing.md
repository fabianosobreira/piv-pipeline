# Slicing reference

Read alongside `SKILL.md`: *Sources* in the Input and Step 1, *Sizing* and *Ticket fields* in Step 3.

## Sources

What you hold sets how you slice:

- **PRD + architecture** (the strong case) — the architecture is **load-bearing**: it names the seams, the data model, the boundaries, and the missing pieces the slices must respect. Slice along those seams.
- **PRD only** — you have the *what*, not the *how*. Slice by outcome, under the skill's *Guard*.
- **Architecture only** — no PRD: the work was architected straight from an idea, a brief or a research doc. Slice along the architecture's seams as in the strong case; its *Problem & goals* stands in for the intent wherever it doesn't cover one.

**From the PRD** — a problem-first PRD gives you no build plan, so decompose from what it does carry:

- **MVP** — the thinnest line that proves the hypothesis end to end. The primary source of tickets: what has to exist for that line to work?
- **Target user & JTBD** — each job-to-be-done becomes one or more tickets, phrased as user-visible outcomes.
- **Success metrics** — anything that has to be measured is itself work; a metric with no way to observe it is a missing ticket.
- **Non-goals** — the boundary every ticket stays inside.
- **Open questions** — surface them, or track them as explicit decision tickets with a decision rule; keep them out of every implementation ticket. A ticket built on an unanswered question is a guess.

**From the architecture, when it exists** — *Recommended approach*, the *Key decisions* sub-sections (*Building blocks*, *Data model*, *Boundaries & contracts*, **Operational shape** — deploy, observability, failure modes, usually its own ticket or two — *Testability* and *Other eng-lead calls*), *Behavior changes vs today* (the checks each replaced rule keeps, changes or drops — every one lands in a ticket's acceptance criteria), *Missing pieces*, and **Spikes & experiments** and its own *Open questions* (the architecture's risky and unsettled calls; same rule as the PRD's *Open questions* — never an implementation ticket). The slicing has to respect those calls — a call labeled **(decided-by-default)** included — and **every named missing piece is usually a ticket**.

## Sizing

The size test is **behavioral, not numeric**. A well-sized ticket:

- Is **one provable concern** — easy to verify, review, and prove on its own.
- Is one coherent unit — a vertical slice of behavior, not a horizontal layer.
- Has clear acceptance criteria of its own.
- Is small enough that **one focused loop can finish it without losing the thread** — not so large that the work drifts and returns diminish.
- Fits on one screen when described — the enumerated *Scope* and *Out of scope* lists aside. A ticket whose description doesn't is two tickets.

Split by **dependency**, by **concern**, or as a **tracer bullet** — a slim end-to-end slice that proves the whole flow thinly, fattened next loop — whatever makes each ticket easiest to prove. The *planning detail* stays high regardless — it's the *scope* that's larger.

*Calibration, not a rule:* for code work with a current-generation agent, this has tended to land around 500–1500 lines of change (a healthy share of it tests) and roughly 8–10 subtasks. Treat those numbers as a sanity check on your own judgment, and recalibrate for the agent, the domain, and work that produces no code at all.

## Ticket fields

- **Title** — imperative and specific (`Add token refresh endpoint`, not `Auth`).
- **Description** — what and why. The sections it traces to go under *Entry context › Decisions*, never here.
- **Root cause** and **Reproduction** — type `bug` only, left out of every other type: taken from the intent or architecture section that states the defect, or from the code read in Step 2, with `path:line` evidence. The repair `piv-implement-ticket` runs on a `bug` ticket needs a root cause and a reproduction, and a root cause belongs to one ticket: the architecture may mix the causes of several tickets, or not exist.
- **Acceptance criteria** — a checklist a reviewer can verify. A criterion that enforces an architecture rule takes one of two forms: it cites the rule's ID — `D<n>`, or `D<n>·<row label>` for a table row — and states a check that stands on its own, a concrete case with its expected outcome; or it quotes the rule verbatim. The criterion is the implementation run's task list, so a paraphrase that changes the rule gets built. A criterion that compares values pins its edges — inclusive or exclusive bounds, date vs datetime, null values, ties — from the sources; an edge no source settles goes on the Step 5 *Unsettled* list, never decided here. A criterion that removes or relaxes a check the code applies today names that check, taken from the architecture's *Behavior changes vs today* when it has one.
- **Scope** — the surfaces it touches, enumerated from Step 2, a rough size, and the docs the change makes stale — comments, docstrings, guides — found by searching for what the change overturns, or "none".
- **Out of scope** — the surfaces in the same role this ticket leaves alone, each with the ticket that owns it or why none does.
- **Entry context** — the four fields of the template: *Decisions*, *Starting code*, *External references* and *Neighbors*. The *Entry context* cites the architecture and the intent and never copies text from them; it holds only what is the ticket's own — starting code, external references, and how the work splits with its neighbors. *Starting code* holds only files inside this repository; every reference to a file outside it goes under *External references*, because the implementation run drift-checks the starting code and cannot open a file outside the repository. The implementation run reads the architecture in full and the intent sections the ticket cites, and a copy can drift from its source. Every reference resolves from the ticket alone — the repository named when it isn't this one. One that can't be resolved or completed from the sources goes on the Step 5 *Unsettled* list.
- **Testing strategy** — the test or check that proves each acceptance criterion, named per criterion. "Project defaults" covers how the checks run, never which ones, and never waives the tests: every behavior the ticket adds or alters still gets one.
- **Type** — `bug`, `feature` or `task`, as `docs/ISSUE-TRACKER.md` defines them under *Creating a ticket*.
