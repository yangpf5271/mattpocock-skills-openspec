---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.

## Tracking progress

In a Matt+OpenSpec flow, the **ticket is the main task flow, OpenSpec is the record**: the tracker (GitLab/GitHub issues, or local `.scratch/` files) is where ticket state is really driven — it's the primary view of who's doing what and what's blocking whom. When an OpenSpec change exists (`openspec/changes/<name>/` exists), `tasks.md` mirrors the tickets 1:1 (see `/to-tickets` step 6) and is the machine-tracked record of that same progress.

So the working order is:

1. **Drive the ticket**: as a slice lands, update its state on the tracker (e.g. GitLab issue → close / in-progress / done; local file → tick its acceptance criteria).
2. **Record it in tasks.md**: after updating the ticket, check the corresponding `- [ ]` off in `openspec/changes/<name>/tasks.md` (each line maps to one acceptance criterion of that ticket). If you skip this, the record lags the ticket — and `openspec archive` reads **only** `tasks.md` for completion, so an unchecked task will block archiving.
3. When the last task is checked, the change is ready for `/archive-proposal`.

Do NOT invent tasks in `tasks.md` that aren't in the ticket breakdown — the tickets are the authority; `tasks.md` records what the tickets say.
