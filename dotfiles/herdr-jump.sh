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
content=$(jq -r '.[].pane_id' <<<"$panes" \
  | while read -r p; do
    herdr pane read "$p" --source recent --format text --lines 200 2>/dev/null \
      | jq -Rs --arg id "$p" '{($id): gsub("[\\s─]+"; " ")}'
  done | jq -s 'add // {}')
branches=$(jq -r '[.[].cwd // empty] | unique[]' <<<"$panes" \
  | while read -r d; do
    jq -n --arg d "$d" --arg b "$(git -C "$d" branch --show-current 2>/dev/null || true)" '{($d): $b}'
  done | jq -s 'add // {}')

# Fields: display, kind, id, preview pane, hidden haystack (titles + cwd + recent output)
sel=$(jq -rn --argjson ws "$ws" --argjson tabs "$tabs" --argjson panes "$panes" --argjson content "$content" --argjson branches "$branches" '
  def nonempty: map(select((. // "") != ""));
  def dim: if . == "" then "" else "  \u001b[2m\(.)\u001b[0m" end;
  ($ws | map({(.workspace_id): .label}) | add) as $names |
  (reduce $panes[] as $p ({}; .[$p.tab_id] //= $p.pane_id)) as $firstPane |
  (reduce $panes[] as $p ({}; .[$p.tab_id] += ([$p.label, $p.terminal_title_stripped, $branches[$p.cwd // ""]] | nonempty))) as $titles |
  (reduce $panes[] as $p ({}; .[$p.workspace_id] += ([$branches[$p.cwd // ""]] | nonempty))) as $wsBranches |
  (reduce $panes[] as $p ({};
    .[$p.tab_id] += " \($p.terminal_title_stripped // "") \($p.cwd // "") \($content[$p.pane_id] // "")")) as $haystack |
  (reduce $tabs[] as $t ({}; .[$t.workspace_id] += ($haystack[$t.tab_id] // ""))) as $wsHaystack |
  ($ws[] | "\(.label)\(($wsBranches[.workspace_id] // []) | unique | join(" · ") | dim)\tworkspace\t\(.workspace_id)\t\($firstPane[.active_tab_id] // "")\t\($wsHaystack[.workspace_id] // "")"),
  ($tabs[] |
    "\($names[.workspace_id]) › \(.label)\(($titles[.tab_id] // []) | unique | join(" · ") | dim)\ttab\t\(.tab_id)\t\($firstPane[.tab_id] // "")\t\($haystack[.tab_id] // "")")
' | fzf --ansi --delimiter='\t' --with-nth=1 --nth=1 --prompt='jump ▸ ' --reverse \
  --header "ctrl-/ toggle content search ('word for exact match)" \
  --bind 'ctrl-/:change-nth(1,5|1)+transform-prompt(if [ "$FZF_NTH" = 1 ]; then echo "jump ▸ "; else echo "jump (content) ▸ "; fi)' \
  --preview "$0 --preview {4}" --preview-window 'right,65%') || exit 0

kind=$(cut -f2 <<<"$sel")
id=$(cut -f3 <<<"$sel")

if [ "$kind" = workspace ]; then
  herdr workspace focus "$id"
else
  herdr tab focus "$id"
fi
