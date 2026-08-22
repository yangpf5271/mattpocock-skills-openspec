#!/usr/bin/env bash
# Structural validator for a codebase atlas.
# Usage: bash validate.sh <atlas-dir> [project-root]
# Checks structure and prints the authoritative counts for the completion
# report. Reading sources and grading evidence stay with the agent; this
# script only catches what is mechanically checkable.
# Exit codes: 0 pass (warnings allowed), 1 structural failure, 2 usage error.

set -u

ATLAS="${1:-}"
ROOT="${2:-.}"

if [ -z "$ATLAS" ]; then
  echo "usage: bash validate.sh <atlas-dir> [project-root]"
  exit 2
fi
if [ ! -d "$ATLAS" ]; then
  echo "FAIL: atlas directory not found: $ATLAS"
  exit 1
fi

fail=0
warns=0
err() { echo "FAIL: $*"; fail=1; }
warn() { echo "WARN: $*"; warns=$((warns + 1)); }

# 1. Required files
for f in INDEX.md overview.md processes.md impact.md completion-report.md; do
  [ -f "$ATLAS/$f" ] || err "missing required file: $f"
done

# 2. Symbol cards: symbols.md, or symbols/ split per module
cards=0
symlist=()
if [ -f "$ATLAS/symbols.md" ]; then
  symlist=("$ATLAS/symbols.md")
elif [ -d "$ATLAS/symbols" ]; then
  for sf in "$ATLAS"/symbols/*.md; do
    [ -f "$sf" ] && symlist+=("$sf")
  done
  [ ${#symlist[@]} -gt 0 ] || err "symbols/ exists but holds no markdown files"
else
  err "neither symbols.md nor symbols/ found"
fi
for sf in "${symlist[@]:-}"; do
  [ -f "$sf" ] || continue
  c=$(grep -c '^### ' "$sf" 2>/dev/null); c=${c:-0}
  cards=$((cards + c))
  grep -q 'Completed at commit' "$sf" || warn "no completion stamp in $(basename "$sf")"
done

# 3. INDEX: freshness table header verbatim; split files listed in the map
idx="$ATLAS/INDEX.md"
if [ -f "$idx" ]; then
  grep -q '^| Region / Symbol | Map lives in | Last completed at | Mode |' "$idx" \
    || err "INDEX: freshness table header missing or altered"
  if [ ${#symlist[@]} -gt 1 ]; then
    grep -q '^| Module | File |' "$idx" \
      || err "INDEX: symbol file map header missing although symbols/ is split"
    for sf in "${symlist[@]}"; do
      grep -q "$(basename "$sf")" "$idx" \
        || err "INDEX: $(basename "$sf") not listed in the symbol file map"
    done
  fi
fi

# 4. Impact: header verbatim; risk vocabulary
imp="$ATLAS/impact.md"
rows=0
if [ -f "$imp" ]; then
  grep -q '^| Symbol | Depends on (d=1) | Dependents (d=1) | Risk | Update order |' "$imp" \
    || err "impact: table header missing or altered"
  bad=$(awk -F'|' '
    /^\|/ && $0 !~ /^[-| ]+$/ && $2 !~ / *Symbol */ {
      risk = $5; gsub(/ /, "", risk)
      if (risk != "" && risk != "LOW" && risk != "MED" && risk != "HIGH" \
          && risk != "CRITICAL" && risk != "UNKNOWN")
        print "impact: undefined risk level: " risk " (row: " $2 ")"
    }' "$imp")
  [ -z "$bad" ] || { echo "$bad"; fail=1; }
  rows=$(awk '/^\|/ && $0 !~ /^[-| ]+$/ && $0 !~ /Symbol \| Depends/ {n++} END {print n+0}' "$imp")
fi

# 5. Processes: every flow has steps; step numbering closes
flows=0
proc="$ATLAS/processes.md"
if [ -f "$proc" ]; then
  flows=$(awk '/^## /{n++} END {print n+0}' "$proc")
  bad=$(awk '
    /^## / { if (sec != "" && n == 0) print "processes: flow without steps: " sec
             sec = $0; n = 0 }
    /Step [0-9]+\/[0-9]+/ { n++ }
    END { if (sec != "" && n == 0) print "processes: flow without steps: " sec }
  ' "$proc")
  [ -z "$bad" ] || { echo "$bad"; fail=1; }
  bad=$(grep -oE 'Step [0-9]+/[0-9]+' "$proc" | awk '
    { split($2, a, "/"); n = a[1]; m = a[2]
      if (n > m) { print "processes: step " n " of " m " exceeds its total"; exc[m] = 1 }
      if (n > max[m]) max[m] = n }
    END { for (m in max) if (max[m] != m && !exc[m])
            print "processes: flow with total " m " never reaches its last step" }
  ')
  [ -z "$bad" ] || { echo "$bad"; fail=1; }
fi

# 6. Evidence grades well-formed: [verified], [inferred], [assumed],
#    or [verified, citation]. A line fails only if a grade token remains
#    after stripping all well-formed ones.
bad=$(grep -rnE '\[(verified|inferred|assumed)' "$ATLAS" --include='*.md' 2>/dev/null \
  | sed -E 's/\[(verified|inferred|assumed)(, [^]]+)?\]//g' \
  | grep -E '\[(verified|inferred|assumed)')
if [ -n "$bad" ]; then
  echo "FAIL: malformed evidence grade (expected [verified], [inferred], [assumed], or [grade, citation]):"
  echo "$bad"
  fail=1
fi

# 6b. Unknown grade-like tokens: a lone lowercase word in brackets that is
#     not one of the three grades (heuristic, so a warning, not a failure)
unknown=$(grep -rnoE '\[[a-z]+(, [^]]+)?\]' "$ATLAS" --include='*.md' 2>/dev/null \
  | grep -vE '\[(verified|inferred|assumed)(,|\])' || true)
[ -n "$unknown" ] && warn "unknown evidence-grade-like token (allowed: verified/inferred/assumed):
$unknown"

# 7. Receipt fields and sections
rep="$ATLAS/completion-report.md"
if [ -f "$rep" ]; then
  for field in 'Run at:' 'Entry:' 'Seeds:' 'Completed:'; do
    grep -q "^- $field" "$rep" || err "receipt: field '$field' missing"
  done
  grep -q '^## Why it stopped' "$rep" || err "receipt: section '## Why it stopped' missing"
  grep -q '^## Remaining blind spots' "$rep" || err "receipt: section '## Remaining blind spots' missing"
fi

# 8. Template boilerplate leaks (warnings: rendered output stays readable)
grep -rq 'Writer guidance, do not copy' "$ATLAS" 2>/dev/null \
  && warn "writer-guidance comments leaked into the atlas"
grep -rq 'One card per mapped symbol' "$ATLAS" 2>/dev/null \
  && warn "symbols template intro copied verbatim"
grep -rq 'The front door to this codebase' "$ATLAS" 2>/dev/null \
  && warn "INDEX template intro copied verbatim"

# 9. AGENTS.md registration (warning: registration is repairable any time)
if [ -f "$ROOT/AGENTS.md" ]; then
  s=$(grep -c 'ATLAS:START' "$ROOT/AGENTS.md" 2>/dev/null); s=${s:-0}
  e=$(grep -c 'ATLAS:END' "$ROOT/AGENTS.md" 2>/dev/null); e=${e:-0}
  if [ "$s" != 1 ] || [ "$e" != 1 ]; then
    warn "AGENTS.md should carry exactly one ATLAS block (START=$s END=$e)"
  fi
fi

echo "counts: symbol_cards=$cards flows=$flows impact_rows=$rows"
echo "counts above are authoritative; copy them into completion-report.md"

if [ "$fail" = 1 ]; then
  echo "RESULT: FAILED"
  exit 1
fi
echo "RESULT: PASS ($warns warning(s))"
