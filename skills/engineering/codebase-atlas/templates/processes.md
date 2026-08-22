# Processes

Named execution flows through the codebase. Each flow is a numbered walk from its trigger to its outcome, one symbol per step.

## <!-- flow name, e.g. "Checkout: happy path" -->

Trigger: <!-- what starts this flow -->

- Step 1/6: `symbol()` <!-- file:line --> -> calls `next()` <!-- async -->
- Step 2/6: `next()` -> calls `db.query()` <!-- external! -->

Annotations: `external!` marks a step that leaves the codebase; note `async`, `error path`, or `conditional` where it changes the story. Keep each flow on one critical path; a branch worth mapping gets its own named flow.
