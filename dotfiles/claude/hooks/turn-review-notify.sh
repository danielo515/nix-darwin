#!/usr/bin/env bash
# Stop: tell the Neovim that owns this working directory what changed this turn.
#
# Neovim listens on a socket keyed by cwd (see home/programs/neovim/ai.nix). If
# no socket exists the session isn't running inside an editor and this is a
# no-op, which is the common case for a plain terminal session.
set -uo pipefail

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$cwd" ] && [ -n "$session" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0

git_dir=$(git rev-parse --git-dir 2>/dev/null) || exit 0
state_dir="$git_dir/claude-turn-review"
base_file="$state_dir/$session.base"
[ -f "$base_file" ] || exit 0
base=$(<"$base_file")
git rev-parse --verify -q "$base^{commit}" >/dev/null 2>&1 || exit 0

changed=$(git diff --name-only "$base" 2>/dev/null | wc -l | tr -d ' ')

# Untracked files are not in the baseline commit, so diff can't see them.
# Anything untracked now that wasn't untracked at turn start is a new file.
added=0
before="$state_dir/$session.untracked"
if [ -f "$before" ]; then
  added=$(comm -13 <(sort "$before") \
                   <(git ls-files --others --exclude-standard 2>/dev/null | sort) \
          | wc -l | tr -d ' ')
fi

[ "$changed" -eq 0 ] && [ "$added" -eq 0 ] && exit 0

# Fixed path rather than $TMPDIR: the hook and Neovim must agree, and TMPDIR
# differs between a login shell and a hook process on macOS.
sock="/tmp/nvim-claude-review-$(id -u)/$(printf '%s' "$cwd" | shasum -a 256 | cut -c1-16).sock"
[ -S "$sock" ] || exit 0
command -v nvim >/dev/null 2>&1 || exit 0

nvim --server "$sock" --remote-expr \
  "luaeval('require\"claude_turn_review\".on_turn_end(_A[1], _A[2], _A[3])', ['$base', $changed, $added])" \
  >/dev/null 2>&1

exit 0
