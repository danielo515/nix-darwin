#!/usr/bin/env bash
# Move a pane into the herdr worktree workspace of the checkout it is in,
# so it nests under its repo in the sidebar.
set -euo pipefail

pane="${1:-${HERDR_ACTIVE_PANE_ID:?no pane given}}"

info=$(herdr pane get "$pane" | jq -c .result.pane)
src_ws=$(jq -r .workspace_id <<<"$info")
cwd=$(jq -r '.foreground_cwd // .cwd' <<<"$info")

checkout=$(git -C "$cwd" rev-parse --show-toplevel)
main=$(dirname "$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)")

workspace_ids() { herdr workspace list | jq -r '.result.workspaces[].workspace_id'; }
before=$(workspace_ids)

opened=$(herdr worktree open --cwd "$main" --path "$checkout" --focus | jq -c .result)
target_ws=$(jq -r .workspace.workspace_id <<<"$opened")
target_tab=$(jq -r .workspace.active_tab_id <<<"$opened")
root_pane=$(jq -r '.root_pane.pane_id // empty' <<<"$opened")

[ "$target_ws" = "$src_ws" ] && exit 0

herdr pane move "$pane" --tab "$target_tab" --split right --focus >/dev/null

if ! grep -qx "$target_ws" <<<"$before" && [ -n "$root_pane" ]; then
  herdr pane close "$root_pane" >/dev/null
fi

if [ "$checkout" != "$main" ] && ! workspace_ids | grep -qx "$src_ws"; then
  herdr worktree open --cwd "$main" --path "$main" --no-focus >/dev/null
fi
