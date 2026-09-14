# AGENTS.md registration block

Write this block into the target project's AGENTS.md: replace it wholesale when the markers already exist, append it when AGENTS.md exists without them, create the file when it is missing. Write AGENTS.md only, never CLAUDE.md.

<!-- ATLAS:START -->
## Codebase atlas

This repo keeps a codebase atlas at `docs/atlas/`: Markdown maps of symbols, execution flows, and change impact, plus preview-verified diagrams under `docs/atlas/images/`, maintained region by region.

- **Read it** before changing code in a region it covers. Start at `docs/atlas/INDEX.md`, then the region's symbol cards and impact rows. A region is stale when `git log <stamp>..HEAD -- <region-path>` is non-empty.
- **Update it** when you change a mapped region: refresh the touched cards, flows, impact rows, and affected diagrams, or run `/codebase-atlas` targeted completion when that skill is installed. A diagram update is complete only after its preview succeeds and its paired PNG is exported.
- **Extend it** before changing code in a region that is unmapped or stale, whenever the change is non-trivial: run `/codebase-atlas` targeted completion first when that skill is installed.
<!-- ATLAS:END -->
