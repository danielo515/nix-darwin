#!/usr/bin/env bash
set -euo pipefail

config=${HERDR_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml}

builtins='[
  ["new_tab", "prefix+c", "New tab"],
  ["new_workspace", "prefix+shift+n", "New workspace"],
  ["split_vertical", "prefix+v", "Split pane right"],
  ["split_horizontal", "prefix+minus", "Split pane down"],
  ["zoom", "prefix+z", "Toggle pane zoom"],
  ["rename_tab", "prefix+shift+t", "Rename tab"],
  ["rename_workspace", "prefix+shift+w", "Rename workspace"],
  ["rename_pane", "prefix+shift+p", "Rename pane"],
  ["close_pane", "prefix+x", "Close pane"],
  ["reload_config", "prefix+shift+r", "Reload config"]
]'

entries() {
  local keys plugin_actions
  keys=$(yq -p toml -o json '.keys // {}' "$config")
  plugin_actions=$(herdr plugin action list 2>/dev/null | jq '[.result.actions[]? | select(.platforms // [] | index("macos"))]' || echo '[]')
  jq -rn --argjson keys "$keys" --argjson builtins "$builtins" --argjson actions "$plugin_actions" '
    def row($label; $key; $kind; $payload):
      "\($label + (" " * ([62 - ($label | length), 2] | max)))\u001b[2m\($key)\u001b[0m\t\($kind)\t\($payload)";
    ($keys.command // [] | to_entries | map(select(.value.command | test("palette") | not))) as $custom |
    ($custom | map(.value.key)) as $taken |
    ($custom | map(.value | if .type == "plugin_action" then .command
      else .command | capture("invoke (?<a>\\S+) --plugin (?<p>\\S+)") | "\(.p).\(.a)" end)) as $bound |
    ($custom[] | .value as $c | row($c.description // $c.command; $c.key; $c.type; .key)),
    ($builtins[] | (($keys[.[0]] // .[1]) as $k | if $k == "" or ($taken | index([$k])) then "" else $k end) as $key |
      row(.[2]; $key; "builtin"; .[0])),
    ($actions[] | "\(.plugin_id).\(.action_id)" as $id | select($bound | index([$id]) | not) |
      row(.title; ""; "plugin_action_unbound"; $id))
  '
}

detach() {
  nohup bash -c 'trap "" HUP TERM; sleep 0.2; "$@"' _ "$@" >/dev/null 2>&1 &
}

invoke_plugin() {
  detach herdr plugin action invoke "${1##*.}" --plugin "${1%.*}"
}

prompt() {
  local reply
  read -rp "$1 ▸ " reply
  [ -n "$reply" ] && printf '%s' "$reply"
}

ws=${HERDR_ACTIVE_WORKSPACE_ID:-$(herdr workspace list | jq -r '.result.workspaces[] | select(.focused) | .workspace_id')}
pane=${HERDR_ACTIVE_PANE_ID:-$(herdr pane list --workspace "$ws" | jq -r '.result.panes[] | select(.focused) | .pane_id')}
tab=${HERDR_ACTIVE_TAB_ID:-$(herdr pane get "$pane" | jq -r ".result.pane.tab_id")}
cwd=${HERDR_ACTIVE_PANE_CWD:-$(herdr pane get "$pane" | jq -r ".result.pane.cwd // empty")}
export HERDR_ACTIVE_WORKSPACE_ID=$ws HERDR_ACTIVE_TAB_ID=$tab HERDR_ACTIVE_PANE_ID=$pane HERDR_ACTIVE_PANE_CWD=${cwd:-$HOME}

sel=$(entries | fzf --ansi --delimiter='\t' --with-nth=1 --nth=1 --prompt='palette ▸ ' --reverse --tiebreak=begin "$@" | head -1) || true
[ -n "$sel" ] || exit 0
kind=$(cut -f2 <<<"$sel")
payload=$(cut -f3 <<<"$sel")

custom() { yq -p toml -o json '.keys.command' "$config" | jq -r ".[$payload].command"; }

case $kind in
  popup) exec bash -c "$(custom)" ;;
  shell) detach bash -c "$(custom)" ;;
  plugin_action) invoke_plugin "$(custom)" ;;
  plugin_action_unbound) invoke_plugin "$payload" ;;
  builtin)
    case $payload in
      new_tab) herdr tab create --workspace "$ws" --cwd "$HERDR_ACTIVE_PANE_CWD" --focus ;;
      new_workspace) herdr workspace create --cwd "$HERDR_ACTIVE_PANE_CWD" --focus ;;
      split_vertical) herdr pane split "$pane" --direction right --cwd "$HERDR_ACTIVE_PANE_CWD" --focus ;;
      split_horizontal) herdr pane split "$pane" --direction down --cwd "$HERDR_ACTIVE_PANE_CWD" --focus ;;
      zoom) herdr pane zoom "$pane" --toggle ;;
      rename_tab) name=$(prompt "tab name") && herdr tab rename "$tab" "$name" ;;
      rename_workspace) name=$(prompt "workspace name") && herdr workspace rename "$ws" "$name" ;;
      rename_pane) name=$(prompt "pane name") && herdr pane rename "$pane" "$name" ;;
      close_pane) detach herdr pane close "$pane" ;;
      reload_config) herdr server reload-config ;;
    esac >/dev/null
    ;;
esac
