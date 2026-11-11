#!/usr/bin/env bash
set -euo pipefail

orphaned_repo_roots() {
  herdr workspace list | jq -r '
    [.result.workspaces[] | .worktree | select(.)]
    | group_by(.repo_root)[]
    | select(all(.is_linked_worktree))
    | .[0].repo_root'
}

orphaned_repo_roots | while IFS= read -r repo_root; do
  [ -d "$repo_root" ] || continue
  herdr worktree open --cwd "$repo_root" --path "$repo_root" --no-focus >/dev/null
done
