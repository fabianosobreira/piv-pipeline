- **Part of**: [the epic's id, in the form `docs/issue-tracker.md` defines; leave the line out when the breakdown has no epic]
- **Spec**: [the spec path] @ [the output of `git hash-object --no-filters [the spec path]`]
- **Slice**: [the id of the task this ticket carries, such as T-01; several ids separated by commas when the user grouped tasks]
- **Blocked by**: [one ticket id, in the form `docs/issue-tracker.md` defines, for each task in another ticket that a task of this slice lists in `Depends on`, separated by commas, or "none"]
- **Size**: [S, M or L]
- **Intent-slug**: [the spec's `Intent-slug`, copied verbatim]
- **Language**: [the spec's `Language`, copied verbatim]

## 1. Goal and context
[every line of section 1 of the spec, copied verbatim]

## 2. Non-goals
[every line of section 2 of the spec, copied verbatim]

## 3. Functional requirements
[the line of each FR that a task of the slice cites, copied verbatim, or "None in this ticket."]

## 4. Non-functional requirements
[the line of each NFR that a task of the slice cites, copied verbatim, or "None in this ticket."]

## 5. Acceptance criteria
[the line of each AC whose head cites at least one FR of the slice, copied verbatim and whole, or "None in this ticket."]

## 6. Technical constraints
[the line of each C that a task of the slice cites, copied verbatim, or "None in this ticket."]

## 7. Design
[the line of each D that a task of the slice cites, copied verbatim, or "None in this ticket."]

## 8. Task plan
[the line of each task of the slice, copied verbatim]

## 9. Verification
[the table header and separator of section 9, then the row of each AC copied to section 5, copied verbatim, or "None in this ticket." alone]

## 10. Boundaries and open questions
### Always
[every line of this level of the spec, copied verbatim, or "None in this ticket."]
### Ask first
[every line of this level of the spec, copied verbatim, or "None in this ticket."]
### Never
[every line of this level of the spec, copied verbatim, or "None in this ticket."]
### Open questions
[the line of each open question that cites an ID of the slice, copied verbatim and whole, or "None in this ticket."]

## Appendix: Decision log
[the table header and separator of the decision log, then the row of each Q cited anywhere in this ticket, copied verbatim]
