# OpenSpec Instance

This repo uses [OpenSpec](https://github.com/Fission-AI/OpenSpec) as the in-repo source of truth for change proposals and evolving specs. Where `/to-spec` publishes a spec to the **issue tracker**, `/to-proposal` sinks the same thinking into the **repo** as an OpenSpec change, and `/archive-proposal` merges each finished change's delta into the living specs.

## Instance location

- **Root:** `openspec/` at the repo root
- **Config:** `openspec/config.yaml` (standard shared config: `schema: spec-driven`; Matt-specific rules stay in the installed skills)
- **Changes (in flight):** `openspec/changes/<change-name>/` — each holds `proposal.md`, `design.md`, `specs/<capability>/spec.md` deltas, and `tasks.md`
- **Main specs (the living source of truth):** `openspec/specs/<capability>/spec.md`
- **Archive (filed changes):** `openspec/changes/archive/YYYY-MM-DD-<change-name>/`

## When a skill says "create an OpenSpec change" (`/to-proposal`)

Run `openspec new change "<name>"` from the repo root, then fill the artifacts it scaffolds under `openspec/changes/<name>/`.

## When a skill says "archive an OpenSpec change" (`/archive-proposal`)

Sync any delta specs under `openspec/changes/<name>/specs/` into `openspec/specs/`, then move the change to `openspec/changes/archive/YYYY-MM-DD-<name>/`.

## CLI

Requires the `openspec` CLI on PATH (`npm install -g @fission-ai/openspec`). Check with `openspec --version`.
