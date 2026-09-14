---
"mattpocock-skills-openspec": patch
---

codebase-atlas: make visual previews a required completion artifact. Atlas runs now keep Mermaid sources under `visuals/`, export every successfully previewed diagram to a paired PNG under `images/`, register the pair in `visuals.md`, and fail structural validation when sources, exports, manifest rows, or PNG signatures are missing.
