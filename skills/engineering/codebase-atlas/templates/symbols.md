# Symbols

One card per mapped symbol, grouped by module.
<!-- Writer guidance, do not copy into the atlas: once this file passes roughly 300 lines or 5 modules, split it into `symbols/<module>.md` and record the split in `INDEX.md`. -->

## <!-- module name -->

### <!-- symbol name --> `(kind: function / class / route / handler)`

- Location: `path/to/file.ts:42` [verified]
- Module: <!-- module -->
- Flows: <!-- named flows from processes.md that pass through it -->
- Calls: `helperA()` [verified, file.ts:50], `db.query()` [verified, external]
- Called by: `router.handle()` [inferred]
- Notes: <!-- invariants, gotchas, anything worth knowing before changing it -->

Completed at commit `<sha>`.

Every fact line carries an evidence grade: `[verified]` with the file:line read that run, `[inferred]`, or `[assumed]`; unknowns get their own line.
<!-- Writer guidance, do not copy into the atlas: never omit an unknown silently; never invent a file:line. -->
