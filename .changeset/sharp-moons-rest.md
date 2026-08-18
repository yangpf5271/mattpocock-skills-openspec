---
"mattpocock-skills-openspec": patch
---

to-proposal: sync prerequisites and guardrails with OpenSpec CLI 1.9.0 — `init --tools none` now creates `config.yaml` itself (fallback kept for older versions), `new change` scaffolds only `.openspec.yaml` (drop the phantom README.md), and zero-delta changes must set `skip_specs: true` in `.openspec.yaml`.
