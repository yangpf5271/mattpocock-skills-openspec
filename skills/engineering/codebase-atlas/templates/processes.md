# Processes

Named execution flows through the codebase. Each flow is a numbered walk from its trigger to its outcome, one symbol per step.

## <!-- flow name, e.g. "Checkout: happy path" -->

Trigger: <!-- what starts this flow -->

- Step 1/6: `symbol()` <!-- file:line --> -> calls `next()` <!-- async -->
- Step 2/6: `next()` -> calls `db.query()` <!-- external! -->

Legend: `external!` marks a step that leaves the codebase; `async`, `error path`, and `conditional` annotate behavior that changes the story.
<!-- Writer guidance, do not copy into the atlas: keep each flow on one critical path; a branch worth mapping gets its own named flow. -->
