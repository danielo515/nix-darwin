#!/usr/bin/env bash
# Forces a naming review when a turn added or renamed identifiers in code.
# Same mechanism as effect-review-gate.sh, kept self-contained on purpose:
#
#   UserPromptSubmit: naming-review-gate.sh snapshot
#   Stop:             naming-review-gate.sh check
#
# `snapshot` records the worktree as a dangling commit plus a content hash of
# every untracked code file. `check` diffs against it so only this turn's edits
# count, then blocks the stop once when an added line declares a name.
set -uo pipefail

mode=${1:-}
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$cwd" ] && [ -n "$session" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0

git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null) || exit 0
git rev-parse --verify -q HEAD >/dev/null 2>&1 || exit 0
state_dir="$git_dir/claude-naming-review"
base_file="$state_dir/$session.base"
untracked_file="$state_dir/$session.untracked"

code_paths=(
  '*.ts' '*.tsx' '*.mts' '*.cts' '*.js' '*.jsx' '*.mjs' '*.cjs'
  '*.py' '*.go' '*.rs' '*.java' '*.kt' '*.swift'
  ':!:*.d.ts' ':!:*.gen.ts' ':!:*.min.js' ':!:**/dist/**' ':!:**/migrations/**'
)

untracked_hashes() {
  git ls-files --others --exclude-standard -- "${code_paths[@]}" 2>/dev/null |
    while IFS= read -r path; do
      [ -f "$path" ] || continue
      printf '%s\t%s\n' "$(git hash-object -- "$path" 2>/dev/null)" "$path"
    done | sort
}

# Added lines that introduce a name: declarations, parameters, lambdas, methods.
declaring_lines() {
  grep -v -E '^[[:space:]]*(//|\*|/\*|#)' |
    grep -E '\b(const|let|var|function|class|interface|type|enum|namespace|def|fn|func|struct|trait|val)[[:space:]]+[A-Za-z_$]|=>|\bcatch[[:space:]]*\(|\b(for|with)[[:space:]]*\(?[[:space:]]*(const|let|var)?[[:space:]]*[A-Za-z_$]|\b[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]*\([^()]*\)[[:space:]]*(:[^=]*)?\{[[:space:]]*$|:=[[:space:]]'
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
  [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = true ] && exit 0
  [ -f "$base_file" ] || exit 0
  base=$(<"$base_file")
  git rev-parse --verify -q "$base^{commit}" >/dev/null 2>&1 || exit 0

  tracked_hits=()
  untracked_hits=()

  while IFS= read -r path; do
    [ -f "$path" ] || continue
    added=$(git diff -U0 "$base" -- "$path" 2>/dev/null | grep '^+' | grep -v '^+++' | cut -c2- | declaring_lines)
    [ -n "$added" ] && tracked_hits+=("$path")
  done < <(git diff --name-only "$base" -- "${code_paths[@]}" 2>/dev/null)

  if [ -f "$untracked_file" ]; then
    while IFS=$'\t' read -r _ path; do
      [ -n "$(declaring_lines <"$path")" ] && untracked_hits+=("$path")
    done < <(comm -13 "$untracked_file" <(untracked_hashes))
  fi

  [ "$((${#tracked_hits[@]} + ${#untracked_hits[@]}))" -gt 0 ] || exit 0

  scopes=$(
    for path in ${tracked_hits[@]+"${tracked_hits[@]}"}; do printf -- '- `git diff %s -- %s`\n' "$base" "$path"; done
    for path in ${untracked_hits[@]+"${untracked_hits[@]}"}; do printf -- '- %s (new file, review whole file)\n' "$path"; done
  )
  reason="Names were added or renamed in code this turn (repo: $cwd).

Before finishing, run the descriptive-naming-reviewer agent on these changes only, with this scope:
$scopes

Then rename what it flags, or report the findings you decide not to fix and why."

  jq -n --arg r "$reason" '{decision: "block", reason: $r}'
  ;;
esac

exit 0
