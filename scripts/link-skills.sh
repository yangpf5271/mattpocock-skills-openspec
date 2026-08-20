#!/usr/bin/env bash
set -euo pipefail

# NOTE: This is a dev-only script, intended for use by maintainers of this repo.
# It is not a supported installer. Modifications to it, or requests for
# modifications, will not be approved.
#
# Links all skills in the repository into the local skill directories used by
# each agent harness:
#   - ~/.claude/skills: Claude Code
#   - ~/.agents/skills: Codex and other Agent Skills-compatible harnesses
# Each entry is a symlink into this repo, so a `git pull` is all that's needed
# to keep installed skills up to date.
#
# On Linux/macOS each entry is a real symlink (`ln -sfn`).
# On Windows (Git Bash / MSYS / Cygwin) a symlink to a directory is not
# reliably creatable from bash — `ln -s` produces a directory *copy*, and
# `ln -sfn` over an existing directory link aborts under `set -e`. So on
# Windows each entry is a *junction* instead (created via PowerShell's
# `New-Item -ItemType Junction`): directory-only, needs no admin rights, and
# resolves transparently to the tools that read these dirs.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

# Detect Windows so we can use junctions instead of POSIX symlinks.
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;;
  *) WINDOWS=0 ;;
esac

# make_link <src> <target> <name>
# Replace <target> with a link to <src>. Works on every platform this script
# supports: symlink on Linux/macOS, junction on Windows.
make_link() {
  local src="$1" target="$2" name="$3"

  if [ "$WINDOWS" -eq 1 ]; then
    # Convert POSIX paths to Windows paths for cmd / PowerShell.
    local wsrc wtarget
    wsrc="$(cygpath -w "$src")"
    wtarget="$(cygpath -w "$target")"

    # Remove whatever is at <target> first. A junction needs a plain `rmdir`
    # (no /s) so the link is removed, not its target's contents; a real
    # directory copy (what a previous broken `ln -s` left behind) needs
    # `rmdir /s /q`. `rmdir` on a non-existent path is harmless via `|| true`.
    if [ -L "$target" ]; then
      cmd //c rmdir "$wtarget" 2>/dev/null || true
    elif [ -e "$target" ]; then
      cmd //c rmdir //s //q "$wtarget" 2>/dev/null || true
    fi

    # Create the junction. PowerShell needs the call operator and quoted
    # args because paths may contain spaces.
    powershell -NoProfile -Command \
      "New-Item -ItemType Junction -Path '$wtarget' -Target '$wsrc' | Out-Null"
  else
    # POSIX: replace whatever is at <target> with a symlink. `-n` stops `ln`
    # from descending into an existing directory symlink; we remove first to
    # be safe across coreutils versions.
    if [ -e "$target" ] || [ -L "$target" ]; then
      rm -rf "$target"
    fi
    ln -sfn "$src" "$target"
  fi
}

# Collect the repo's skills once, link into every destination.
names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0)

for DEST in "${DESTS[@]}"; do
  # If $DEST is a symlink that resolves into this repo, we'd end up writing the
  # per-skill links back into the repo's own skills/ tree. Detect and bail out
  # instead of polluting the working copy.
  if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"

    make_link "$src" "$target" "$name"
    echo "linked $name -> $src ($DEST)"
  done
done
