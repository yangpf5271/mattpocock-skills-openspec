# Atlas Index

The front door to this codebase's atlas. Read this first: it tells you where every region's map lives and how fresh it is.

## Region freshness

| Region / Symbol | Map lives in | Last completed at | Mode |
| --- | --- | --- | --- |
| <!-- `src/orders/checkout()` | `symbols/orders.md` | `a1b2c3d` | targeted d=2 --> |

`Last completed at` is the commit the region was last completed against. A region is stale when `git log <commit>..HEAD -- <region-path>` is non-empty; refresh it with targeted completion before relying on it.

## Symbol file map

| Module | File |
| --- | --- |
| <!-- `orders` | `symbols/orders.md` --> |

Present only once `symbols.md` has been split; until then all cards live in `symbols.md`.

## Files

- `overview.md`: stack, entry points, feature clusters, external boundaries
- `processes.md`: named execution flows
- `symbols.md` (or `symbols/<module>.md`): symbol cards
- `impact.md`: dependency rings, risk levels, update order
- `completion-report.md`: receipt of the latest completion run
