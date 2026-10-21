#!/usr/bin/env bash
# Forces an Effect review when a turn changed Effect code. Subagent descriptions
# are only hints, so without this the main agent routinely skips the reviewers.
#
#   UserPromptSubmit: effect-review-gate.sh snapshot
#   Stop:             effect-review-gate.sh check
#
# `snapshot` records the worktree as a dangling commit (`git stash create` moves
# no ref and leaves the worktree and staged content alone; `git gc` prunes it)
# plus a content hash of every untracked file, which that commit can't hold.
# `check` diffs against it so only this turn's edits count, then blocks the stop
# once when an added line in an Effect-importing file looks like Effect code.
# Self-contained on purpose: it shares nothing with the turn-review hooks.
set -uo pipefail

mode=${1:-}
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$cwd" ] && [ -n "$session" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0

git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null) || exit 0
git rev-parse --verify -q HEAD >/dev/null 2>&1 || exit 0
state_dir="$git_dir/claude-effect-review"
base_file="$state_dir/$session.base"
untracked_file="$state_dir/$session.untracked"

ts_paths=('*.ts' '*.tsx' '*.mts' '*.cts')

# "<hash>\t<path>" per untracked TS file, sorted. hash-object without -w only
# computes the id; it writes nothing.
untracked_hashes() {
  git ls-files --others --exclude-standard -- "${ts_paths[@]}" 2>/dev/null |
    while IFS= read -r path; do
      [ -f "$path" ] || continue
      printf '%s\t%s\n' "$(git hash-object -- "$path" 2>/dev/null)" "$path"
    done | sort
}

imports_effect() {
  grep -Eq "from ['\"](effect|@effect/)|import\(['\"](effect|@effect/)" -- "$1" 2>/dev/null
}

# Added lines that look like Effect code, ignoring comment-only lines.
effect_lines() {
  grep -v -E '^[[:space:]]*(//|\*|/\*)' |
    grep -E "\b(Effect|Layer|Schema|Context|ServiceMap|Stream|Scope|Fiber|Option|Exit|Cause|Data|Match|Config|Schedule|Queue|Ref|Logger|Metric)\.[A-Za-z]|yield\*|\.pipe\(|['\"](effect|@effect/)"
}

case "$mode" in
snapshot)
  mkdir -p "$state_dir"
  find "$state_dir" -maxdepth 1 -type f -mtime +7 -delete 2>/dev/null
  base=$(git stash create 2>/dev/null)
  [ -n "$base" ] || base=$(git rev-parse HEAD)
  printf '%s\n' "$base" >"$base_file"
  untracked_hashes >"$untracked_file"
  ;;

check)
  # Second stop after our block: the review already ran, let the turn end.
  [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = true ] && exit 0
  [ -f "$base_file" ] || exit 0
  base=$(<"$base_file")
  git rev-parse --verify -q "$base^{commit}" >/dev/null 2>&1 || exit 0

  hits=()
  needs_log_review=false

  # Tracked files: only the lines this turn added.
  while IFS= read -r path; do
    [ -f "$path" ] && imports_effect "$path" || continue
    added=$(git diff -U0 "$base" -- "$path" 2>/dev/null | grep '^+' | grep -v '^+++' | cut -c2- | effect_lines)
    [ -n "$added" ] || continue
    hits+=("$path")
    printf '%s' "$added" | grep -Eq 'annotateLogs|withLogSpan|Effect\.log' && needs_log_review=true
  done < <(git diff --name-only "$base" -- "${ts_paths[@]}" 2>/dev/null)

  # Untracked files new or changed this turn: no prior content to diff against,
  # so the whole file counts.
  if [ -f "$untracked_file" ]; then
    while IFS=$'\t' read -r _ path; do
      imports_effect "$path" || continue
      added=$(effect_lines <"$path")
      [ -n "$added" ] || continue
      hits+=("$path")
      printf '%s' "$added" | grep -Eq 'annotateLogs|withLogSpan|Effect\.log' && needs_log_review=true
    done < <(comm -13 "$untracked_file" <(untracked_hashes))
  fi

  [ "${#hits[@]}" -gt 0 ] || exit 0

  files=$(printf '%s\n' "${hits[@]}")
  agents="the effect-ts-enforcer agent"
  $needs_log_review && agents="the effect-ts-enforcer and effect-log-annotations agents (in parallel)"
  reason="Effect code changed this turn in:
$files

Before finishing, run $agents on these changes only. Give them this scope: \`git diff $base -- <file>\` for tracked files (repo: $cwd); whole file for untracked ones. Then fix what they find, or report findings you decide not to fix and why."

  jq -n --arg r "$reason" '{decision: "block", reason: $r}'
  ;;
esac

exit 0
