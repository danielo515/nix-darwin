#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "--preview" ]; then
  [ -n "${2:-}" ] || {
    echo "(no pane)"
    exit 0
  }
  herdr pane read "$2" --source visible --format ansi --lines 60 2>/dev/null || echo "(unreadable)"
  exit 0
fi

ws=$(herdr workspace list | jq '.result.workspaces')
tabs=$(herdr tab list | jq '.result.tabs')
panes=$(jq -rn --argjson ws "$ws" '$ws[].workspace_id' \
  | while read -r w; do herdr pane list --workspace "$w" | jq '.result.panes'; done \
  | jq -s 'add')

sel=$(jq -rn --argjson ws "$ws" --argjson tabs "$tabs" --argjson panes "$panes" '
  ($ws | map({(.workspace_id): .label}) | add) as $names |
  (reduce $panes[] as $p ({}; .[$p.tab_id] //= $p.pane_id)) as $firstPane |
  ($ws[] | "\(.label)\tworkspace\t\(.workspace_id)\t\($firstPane[.active_tab_id] // "")"),
  ($tabs[] | "\($names[.workspace_id]) › \(.label)\ttab\t\(.tab_id)\t\($firstPane[.tab_id] // "")")
' | fzf --delimiter='\t' --with-nth=1 --prompt='jump ▸ ' --reverse \
  --preview "$0 --preview {4}" --preview-window 'right,65%') || exit 0

kind=$(cut -f2 <<<"$sel")
id=$(cut -f3 <<<"$sel")

if [ "$kind" = workspace ]; then
  herdr workspace focus "$id"
else
  herdr tab focus "$id"
fi
