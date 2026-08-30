---
name: implement
description: "规格就绪、准备动手时：Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the repo keeps a codebase atlas (`docs/atlas/`; see `/codebase-atlas`) covering a region this work touches, read those pages before coding. If a touched region is unmapped or stale and the change is non-trivial, run `/codebase-atlas` targeted completion on it first. After committing, refresh the touched region's map (incremental update).

Use /tdd where possible, at pre-agreed seams.

Keep the documents truthful in the same change. When the work renames or removes a term, command, or field that any document references, update every reference now and leave a mechanical guard (a test or a grep assertion) so the old name cannot silently return; when a document promises behavior, the test proving it lands in the same change.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

After the review passes, run acceptance before calling the work done. Run the full test suite. If the change touches a UI surface, its spec-scenario journeys need verifying; three ways, take the first that fits unless the user says otherwise:

- **Committed E2E**: when the repo has browser E2E infrastructure, run the E2E journeys covering this change's spec scenarios. Preferred where it exists: the specs are committed and re-run as regression on every later change.
- **Agent browser walkthrough**: when the harness provides browser automation tools, walk the route yourself: start the dev server (or ask the user to), then one browser route per scenario, screenshotting each step and judging what the screenshot shows against the scenario's expected observable result. Present the screenshots and per-scenario verdicts to the user; a scenario whose expectation is look and feel waits for explicit user confirmation on the screenshot. No test files are committed, so this verifies this change only.
- **Manual acceptance route**: output the journeys as a walkthrough for the user to click through: one numbered route per scenario, each step naming the page, the action, and the expected observable result. The user reports pass or fail per scenario.

A failure in any mode comes back here as a bug report before the work counts as done. When the harness has no browser tools and the repo has no infrastructure, the manual route is the default.

If the repo has no test infrastructure at all, do not skip silently: report that the spec scenarios have no executable verification and ask whether to scaffold minimal infrastructure now (a single test runner for logic-only changes; a minimal Playwright skeleton for UI changes), verify the UI scenarios by agent browser walkthrough, verify them by manual acceptance route, or skip with the gap recorded in the change.

Commit your work to the current branch.

## Tracking progress

When an OpenSpec change exists (`openspec/changes/<name>/` exists), `tasks.md` is the OpenSpec implementation checklist and archive record. Work it in one of two modes:

1. **Tickets exist** (because `/to-tickets` promoted the checklist groups): drive the ticket first on the tracker (GitLab/GitHub issues, or local `.scratch/` files), then check off the corresponding `- [ ]` lines in `openspec/changes/<name>/tasks.md` as that slice lands. Ticket state is the collaboration surface; `tasks.md` is the OpenSpec record.
2. **No tickets exist** (lightweight OpenSpec flow): work directly from `tasks.md`, implementing the vertical slices in order and checking each `- [ ]` off as it lands.

In both modes, keep `tasks.md` accurate. `openspec archive` reads **only** `tasks.md` for completion, so an unchecked item will make the archive preflight report incomplete work. When the last task is checked, the change is ready for `/archive-proposal`.

Do NOT invent new OpenSpec checklist items during implementation unless the source plan was genuinely missing required work. If tickets exist, keep their acceptance criteria and the matching `tasks.md` lines in sync.
