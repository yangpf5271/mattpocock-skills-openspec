---
name: codebase-atlas
description: "改动不熟悉的代码区域、或图谱缺失/过期时：Build and maintain a persistent codebase atlas under docs/atlas/ as plain Markdown committed to the repo: symbol cards, named execution flows, impact rings with risk levels, and per-region freshness. One completion engine with three entries: full generation (asks the user first), incremental update from git diff, and targeted completion around whatever you are about to change."
---

# Codebase Atlas

A persistent knowledge layer for a codebase: plain Markdown, committed to the repo, readable by humans and any agent, maintained region by region instead of regenerated whole.

Session-scoped exploration (grep, repomaps, one-off summaries) is discarded when the session ends. The atlas is not: it survives, it goes through code review, and it gets refreshed only where code actually changed.

## When to reach for this

- You are about to change a region you do not know, and the repo has no atlas, or a stale one, for it.
- The same "how does X work" question keeps coming back across sessions; the answer should be written down once.
- A review or a diagnosis needs caller and risk context that the diff alone does not show.

Skip it when the change is trivial, the region's map is already fresh, a throwaway grep answers the question, or the repo is small enough to hold in one read.

## What lives where

The atlas lives in the target project at `docs/atlas/` by default (the user may point it elsewhere; the AGENTS.md block records the actual location):

- `INDEX.md`: the front door. Region freshness table and the symbol-file map. Lookup starts here.
- `overview.md`: stack, entry points, feature clusters, external boundaries (databases, HTTP, queues, third-party SDKs).
- `processes.md`: named execution flows, step by step.
- `symbols.md`: one card per mapped symbol (split per module once large; see below).
- `impact.md`: for each mapped symbol, its direct dependencies (d=1), a risk level, and an update order.
- `completion-report.md`: receipt of the latest completion run. Only the latest is kept; history belongs to git.
- An AGENTS.md registration block, so every agent working in the repo knows the atlas exists and when to consult it.

Write atlas content in the target project's dominant documentation language (Chinese-first when its docs are mostly Chinese; English when they are mostly English). Keep structural tokens (evidence grades, table headers from the templates) in English so they stay greppable either way.

## Three entries, one engine

- **Targeted completion** (the default). Given a symbol, file, or region that the user, or another skill such as `/implement`, is about to change: map only the surrounding code, ring by ring, then stop. Cheap and high frequency; this is the only entry another skill may trigger on its own.
- **Incremental update.** After changes land, re-run the engine only for symbols the git diff touched, refreshing their cards, flows, and impact rows.
- **Full generation.** Build the atlas from scratch, seeded from entry points and key modules. Expensive: confirm scope and a symbol budget with the user before starting. Never begin a full generation on your own initiative.

A fourth mode, **lookup**, is read-only: answer the question from the existing atlas (`INDEX.md` first) without writing anything.

## The completion engine

Run these seven steps for every entry; the entries differ only in how seeds are chosen (a user-named symbol; symbols hit by `git diff`; entry points for full generation).

1. **Locate the seed.** Find the file and line of the seed symbol (grep; tree-sitter or ctags when available). If the seed cannot be found, say so and stop; never guess a location.
2. **Read the seed's source** and record card facts: file:line, kind, module, what it calls, what calls it.
3. **Trace d=1 edges.** For each caller and callee, record the edge with an evidence grade (below). Never record a file:line you have not read this run; grade the edge `[inferred]` instead.
4. **Apply EXPAND / STOP** (below) to decide whether one more ring is worth mapping.
5. **Repeat ring by ring** until a STOP condition holds. Ring d means calls at d hops from the seed.
6. **Write back** to the affected atlas files from the templates: cards to `symbols.md` (or the module file), flows to `processes.md`, dependency rows to `impact.md`, freshness stamps to `INDEX.md`. Stamp every written card with the commit this completion runs against.
7. **Run the quality gate**, then write `completion-report.md` (replacing the previous one). Update the AGENTS.md block only when the atlas layout changed.

## EXPAND / STOP

Expand one more ring when any of these holds:

- the ring touches a public interface, route, or exported symbol;
- an edge crosses a module boundary;
- an edge graded `[inferred]` sits on a critical path;
- the seed itself is on a critical path (payment, auth, data migration, startup).

Stop when any of these holds:

- the branch reaches an external boundary (database, HTTP, queue, third-party SDK): record the boundary and stop that branch;
- a full ring yields no new critical-path symbols;
- **d=3**, a hard cap; deeper impact belongs to a fresh completion seeded there;
- the symbol budget for the project scale is spent (rough guide: small repo about 40 symbols, medium about 120, large about 300).

## Freshness

A region is stale when commits touched its paths after its last completion stamp:

```
git log <stamp>..HEAD --oneline -- <region-path>
```

Non-empty output means stale; refresh it with targeted completion before relying on it. In a project without git, fall back to comparing file modification dates against the atlas's date stamps.

## Evidence grading

Every edge and every card fact carries one of:

- `[verified]`: you read that file:line during this run. Must cite it.
- `[inferred]`: strong signal (naming, imports, call sites you did read), but the line itself was not read.
- `[assumed]`: a reasonable guess, marked so a later run can verify or kill it.

Unknowns get their own line in `symbols.md` / `impact.md`; never omit them silently. Never invent a file:line.

## Skip rules

Never map `node_modules/`, `dist/`, `build/`, `vendor/`, generated code, minified bundles, or binaries. Read `.gitignore` for extra clues about what is generated. If a seed lands inside skipped territory, report that and stop.

## Symbol file splitting

When `symbols.md` passes roughly 300 lines or covers more than 5 modules, split it into `symbols/<module>.md`, one module per file, and record the mapping in `INDEX.md`. Targeted completion then reads and writes only the one or two module files it touches.

## Quality gate

Before writing the completion report:

1. Every `[verified]` edge cites a file:line actually read during this run.
2. Spot-check 3 new edges: re-read their cited lines. Any mismatch, or any cited line you cannot account for having read, fails the gate.
3. The completion report's counts match the files as written: count the cards, flows, and impact rows you actually wrote (grep the headings), never from memory.
4. On failure, fix the entries and re-run the check. Never lower a grade to pass the gate.

The bundled [validate.sh](./validate.sh) checks the structural half mechanically: `bash <this-skill-folder>/validate.sh <atlas-dir> <project-root>`. It fails on breakage (missing files, altered table headers, malformed evidence grades, step numbering, receipt fields), warns on template leakage, and prints the authoritative card/flow/row counts; take item 3's numbers from its output. Where bash is unavailable, run the checks by hand.

## AGENTS.md registration

Register the atlas in the target project's AGENTS.md from the block template: idempotent `<!-- ATLAS:START -->` / `<!-- ATLAS:END -->` markers, replaced wholesale when present, appended when the file exists without them, creating the file when missing. Write AGENTS.md only, never CLAUDE.md. The block states what each file is for, when to read the atlas, when to update it, and instructs: before changing code in a region whose map is missing or stale, run targeted completion first.

## Templates

Write every atlas file from these templates; keep the table headers verbatim so the atlas stays mechanically parseable. Templates mix two kinds of text: reader-facing notation keys and table headers, which you keep; and writer guidance in `<!-- -->` comments and placeholder rows, which you never copy into the atlas.

- [templates/INDEX.md](./templates/INDEX.md): front door, freshness table, symbol-file map
- [templates/overview.md](./templates/overview.md): stack, entry points, feature clusters, external boundaries
- [templates/processes.md](./templates/processes.md): named execution flows
- [templates/symbols.md](./templates/symbols.md): symbol cards with evidence grades
- [templates/impact.md](./templates/impact.md): dependency rings, risk levels, update order
- [templates/completion-report.md](./templates/completion-report.md): receipt of the latest run
- [templates/agents-block.md](./templates/agents-block.md): the AGENTS.md registration block
