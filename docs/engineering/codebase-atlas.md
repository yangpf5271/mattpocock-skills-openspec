## What it does

`codebase-atlas` builds and maintains a persistent knowledge layer for a codebase: plain Markdown maps under `docs/atlas/`, committed to the repo, readable by humans and any agent, refreshed region by region instead of regenerated whole.

The atlas holds six files: `INDEX.md` (front door, region freshness table, symbol-file map), `overview.md` (stack, entry points, feature clusters, external boundaries), `processes.md` (named execution flows, step by step), `symbols.md` (one card per mapped symbol, with evidence grades), `impact.md` (direct dependencies, risk levels, update order), and `completion-report.md` (receipt of the latest run, latest only). An idempotent block in the target project's AGENTS.md tells every agent the atlas exists and when to consult it.

Everything is written from templates in the skill folder, so the format stays mechanically parseable no matter which agent (or person) ran the last completion. A bundled `validate.sh` checks that structure mechanically: it fails on breakage, warns on template leakage, and prints the authoritative card/flow/impact-row counts for the completion report.

## When to reach for it

Model-invoked: the agent reaches for it when it is about to change a region it does not know and the repo has no map (or a stale one) for it, or when the same "how does X work" question keeps returning across sessions.

| Situation | Entry |
| --- | --- |
| About to change a symbol/region (the default, also what `/implement` triggers) | Targeted completion: map only the surrounding code, ring by ring, then stop |
| Changes just landed in a mapped region | Incremental update: re-run the engine only for symbols the git diff touched |
| New repo, no atlas yet | Full generation: seeds from entry points; confirms scope and a symbol budget with you first |
| Just asking "how does X work" | Lookup: read-only, `INDEX.md` first |

Skip it when the change is trivial, the region's map is fresh, a throwaway grep answers the question, or the repo is small enough to hold in one read. Full generation always asks first; no agent should ever kick off a whole-repo scan on its own initiative.

## Common questions

**How is this different from just grepping?**

Grep answers one question once, in this session. The atlas writes the answer down, commits it, and stamps it with the commit it was verified against. The next session (or the next agent, or a teammate) starts from the map instead of from zero, and only re-reads what has actually changed since the stamp.

**How does it avoid mapping the world?**

Every completion run obeys EXPAND/STOP rules. It expands a ring when the code touches public interfaces, crosses module boundaries, or sits on a critical path; it stops at external boundaries (databases, HTTP, queues, SDKs), when a ring yields nothing new, at a hard depth cap of d=3, or when the project-scale symbol budget is spent. Why it stopped is recorded in the completion report.

**Can I trust what it wrote?**

Every fact line carries an evidence grade: `[verified]` (the file:line was actually read this run, and must be cited), `[inferred]` (strong signal, line unread), or `[assumed]` (a marked guess). A quality gate spot-checks three new edges per run by re-reading them; a cited line nobody read fails the gate.

**What if the repo is not on git?**

Freshness normally comes from `git log <stamp>..HEAD -- <region-path>` (non-empty means stale). Without git, the atlas falls back to comparing file modification dates against its date stamps.

**Does it touch CLAUDE.md?**

No. Registration goes into AGENTS.md only, between idempotent `ATLAS:START`/`ATLAS:END` markers: replaced when present, appended when absent, created when missing.

## It's working if

- `docs/atlas/INDEX.md` answers "where is the map for X and is it fresh" without opening anything else.
- Every `[verified]` edge cites a file:line; spot-checked edges re-read correctly.
- A targeted completion touches only the one or two symbol files it needs, not the whole atlas.
- `completion-report.md` says what was completed, the final radius, why it stopped, and what is still blind.
- Regions you changed last month show as stale; regions nobody touched still show their original stamps.
- The AGENTS.md block is present exactly once, and reading it is enough for a fresh agent to use the atlas correctly.
- `bash validate.sh docs/atlas .` (bundled with the skill) passes, and the receipt's counts match the counts it prints.

## Where it fits

`codebase-atlas` runs underneath the working skills rather than on the main flow:

```text
implement ──────── reads atlas before coding; targeted-completes unmapped or stale regions; refreshes the touched region after commit
code-review ────── feeds changed symbols' impact/symbol cards to its sub-agents
diagnosing-bugs ── traces execution through processes.md/symbols.md before ad-hoc grep
```

It is read-side infrastructure: it changes no spec, ticket, or OpenSpec lifecycle behavior, and it costs nothing in repos without an atlas. In repos with one, every `/implement`, `/code-review`, and `/diagnosing-bugs` run starts from verified, versioned context instead of a cold grep. `ask-matt` routes where it fits.
