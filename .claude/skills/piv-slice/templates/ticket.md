- **Spec**: [the spec path] @ [the output of `git hash-object --no-filters [the spec path]`]
- **Task**: [the id of the one task this ticket carries, such as T-01]
- **Title**: [the task's title: an imperative sentence naming one outcome]
- **Type**: [bug, feature or none]
- **Blocked by**: [each task that must be done first, as T-xx ids separated by commas, or "none"]
- **Size**: [S, M or L]
- **DoD**: [the AC ids the task proves, separated by commas, such as AC-01, AC-02]
- **Cites**: [the NFR, C and D ids the task needs, separated by commas, or "none"]
- **Intent-slug**: [the spec's `Intent-slug`, copied verbatim]
- **Language**: [the spec's `Language`, copied verbatim]

## 1. Goal and context
[every line of section 1 of the spec, copied verbatim]

## 2. Non-goals
[every line of section 2 of the spec, copied verbatim]

## 3. Functional requirements
[the line of each FR that an AC of the DoD cites, copied verbatim, or "None in this ticket."]

## 4. Acceptance criteria
[the line of each AC of the DoD, copied verbatim and whole]

## 5. Non-functional requirements
[the line of each NFR in Cites, copied verbatim, or "None in this ticket."]

## 6. Technical constraints
[the line of each C in Cites, copied verbatim, or "None in this ticket."]

## 7. Design
[the line of each D in Cites, copied verbatim, or "None in this ticket."]

## 8. Boundaries and open questions
### Always
[every line of this level of the spec, copied verbatim, or "None in this ticket."]
### Ask first
[every line of this level of the spec, copied verbatim, or "None in this ticket."]
### Never
[every line of this level of the spec, copied verbatim, or "None in this ticket."]
### Open questions
[the line of each open question that cites an ID the ticket carries, copied verbatim and whole, or "None in this ticket."]

## 9. Verification
[the table header and separator of section 9, then the row of each AC of the DoD, copied verbatim]

## Appendix: Decision log
[the table header and separator of the decision log, then the row of each Q cited anywhere in this ticket, copied verbatim]
