#!/usr/bin/env bash
set -euo pipefail

ws=$(herdr workspace list | jq '.result.workspaces')
tabs=$(herdr tab list | jq '.result.tabs')

sel=$(jq -rn --argjson ws "$ws" --argjson tabs "$tabs" '
  ($ws | map({(.workspace_id): .label}) | add) as $names |
  ($ws[] | "\(.label)\tworkspace\t\(.workspace_id)"),
  ($tabs[] | "\($names[.workspace_id]) › \(.label)\ttab\t\(.tab_id)")
' | fzf --delimiter='\t' --with-nth=1 --prompt='jump ▸ ' --reverse) || exit 0

kind=$(cut -f2 <<<"$sel")
id=$(cut -f3 <<<"$sel")

if [ "$kind" = workspace ]; then
  herdr workspace focus "$id"
else
  herdr tab focus "$id"
fi
