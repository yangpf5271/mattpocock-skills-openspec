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

When the work is an OpenSpec change (`openspec/changes/<name>/` exists), **`tasks.md` is the single source of truth for task status** — it mirrors the tickets (see `/to-tickets` step 6). Check each `- [ ]` off in `tasks.md` as its ticket lands; ticket files on the tracker are a *view* over `tasks.md`, so do NOT double-bookkeep them. When the last task is checked, the change is ready for `/archive-proposal`.
