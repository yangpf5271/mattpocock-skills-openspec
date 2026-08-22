---
name: implement
description: "规格就绪、准备动手时：Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the repo keeps a codebase atlas (`docs/atlas/`; see `/codebase-atlas`) covering a region this work touches, read those pages before coding. If a touched region is unmapped or stale and the change is non-trivial, run `/codebase-atlas` targeted completion on it first. After committing, refresh the touched region's map (incremental update).

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.

## Tracking progress

When an OpenSpec change exists (`openspec/changes/<name>/` exists), `tasks.md` is the OpenSpec implementation checklist and archive record. Work it in one of two modes:

1. **Tickets exist** (because `/to-tickets` promoted the checklist groups): drive the ticket first on the tracker (GitLab/GitHub issues, or local `.scratch/` files), then check off the corresponding `- [ ]` lines in `openspec/changes/<name>/tasks.md` as that slice lands. Ticket state is the collaboration surface; `tasks.md` is the OpenSpec record.
2. **No tickets exist** (lightweight OpenSpec flow): work directly from `tasks.md`, implementing the vertical slices in order and checking each `- [ ]` off as it lands.

In both modes, keep `tasks.md` accurate. `openspec archive` reads **only** `tasks.md` for completion, so an unchecked item will make the archive preflight report incomplete work. When the last task is checked, the change is ready for `/archive-proposal`.

Do NOT invent new OpenSpec checklist items during implementation unless the source plan was genuinely missing required work. If tickets exist, keep their acceptance criteria and the matching `tasks.md` lines in sync.
