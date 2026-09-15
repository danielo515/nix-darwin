#!/usr/bin/env bash
# UserPromptSubmit: snapshot the worktree so the Stop hook can show exactly what
# this turn changed.
#
# `git stash create` writes a commit object for the current WIP without touching
# the worktree, the index, or any ref, so this is invisible to the user's own git
# state. Untracked files are recorded separately because they are absent from
# that commit and so would never appear in a `git diff` against it.
set -uo pipefail

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$cwd" ] && [ -n "$session" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0

git_dir=$(git rev-parse --git-dir 2>/dev/null) || exit 0
git rev-parse --verify -q HEAD >/dev/null 2>&1 || exit 0

base=$(git stash create 2>/dev/null)
# Empty means a clean worktree: HEAD already describes it.
[ -n "$base" ] || base=$(git rev-parse HEAD)

state_dir="$git_dir/claude-turn-review"
mkdir -p "$state_dir"
printf '%s\n' "$base" >"$state_dir/$session.base"
git ls-files --others --exclude-standard >"$state_dir/$session.untracked" 2>/dev/null

exit 0
