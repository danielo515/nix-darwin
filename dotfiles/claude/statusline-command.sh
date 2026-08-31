#!/usr/bin/env bash
# Claude Code status line — styled to match Starship prompt aesthetics

input=$(cat)

# Extract fields
user=$(whoami)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end // ""')
branch=$(echo "$input" | jq -r '.worktree.branch // ""')
if [ -z "$branch" ] && [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
fi
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# ANSI colors (will be dimmed by Claude Code)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

# Nerd Font icons (Material Design range, written as escapes to survive editing)
ICON_USER=$'\U000F0004'   # nf-md-account
ICON_DIR=$'\U000F024B'    # nf-md-folder
ICON_REPO=$'\U000F02A4'   # nf-md-github
ICON_BRANCH=$'\U000F062C' # nf-md-source_branch
ICON_MODEL=$'\U000F06A9'  # nf-md-robot
ICON_CTX=$'\U000F035B'    # nf-md-memory

# Shorten cwd: replace $HOME with ~
cwd="${cwd/#$HOME/\~}"

# Build segments
parts=()

# user@cwd
parts+=("$(printf "${CYAN}%s %s${RESET}:${BLUE}%s %s${RESET}" "$ICON_USER" "$user" "$ICON_DIR" "$cwd")")

# model
if [ -n "$model" ]; then
  parts+=("$(printf "${YELLOW}%s %s${RESET}" "$ICON_MODEL" "$model")")
fi

# context usage
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="$RED"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
  if [ -n "$total_input" ] && [ -n "$ctx_size" ]; then
    used_k=$(echo "$total_input" | awk '{ printf "%.0f", $1/1000 }')
    total_k=$(echo "$ctx_size" | awk '{ printf "%.0fk", $1/1000 }')
    parts+=("$(printf "%s ${ctx_color}%s%%${RESET} \033[2m%s/%s\033[0m" "$ICON_CTX" "$used_int" "$used_k" "$total_k")")
  else
    parts+=("$(printf "%s ${ctx_color}%s%%${RESET}" "$ICON_CTX" "$used_int")")
  fi
fi

# git repo + branch (kept separate so it can wrap to its own line)
git_part=""
if [ -n "$repo" ]; then
  if [ -n "$branch" ]; then
    git_part="$(printf "${GREEN}%s %s${RESET} ${MAGENTA}%s %s${RESET}" "$ICON_REPO" "$repo" "$ICON_BRANCH" "$branch")"
  else
    git_part="$(printf "${GREEN}%s %s${RESET}" "$ICON_REPO" "$repo")"
  fi
fi

join_parts() {
  local result="" part
  for part in "$@"; do
    [ -z "$part" ] && continue
    if [ -z "$result" ]; then
      result="$part"
    else
      result="$result $(printf '\033[2m|\033[0m') $part"
    fi
  done
  printf '%s' "$result"
}

visible_len() {
  local plain
  plain=$(printf '%b' "$1" | sed $'s/\x1b\[[0-9;]*m//g')
  printf '%s' "${#plain}"
}

full_line=$(join_parts "${parts[@]}" "$git_part")

# Wrap: if the full bar doesn't fit the terminal, move repo+branch to a second line
if [ -n "$git_part" ] && [ -n "${COLUMNS:-}" ] && [ "$(visible_len "$full_line")" -gt "$COLUMNS" ]; then
  printf "%b\n" "$(join_parts "${parts[@]}")"
  printf "%b\n" "$git_part"
else
  printf "%b\n" "$full_line"
fi
