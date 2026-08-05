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

# Shorten cwd: replace $HOME with ~
cwd="${cwd/#$HOME/\~}"

# Build segments
parts=()

# user@cwd
parts+=("$(printf "${CYAN} %s${RESET}:${BLUE}󰉋 %s${RESET}" "$user" "$cwd")")

# git repo + branch
if [ -n "$repo" ]; then
  if [ -n "$branch" ]; then
    parts+=("$(printf "${GREEN} %s${RESET} ${MAGENTA} %s${RESET}" "$repo" "$branch")")
  else
    parts+=("$(printf "${GREEN} %s${RESET}" "$repo")")
  fi
fi

# model
if [ -n "$model" ]; then
  parts+=("$(printf "${YELLOW}󰚩 %s${RESET}" "$model")")
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
  # Build context string: show tokens/total when available, always show percentage
  if [ -n "$total_input" ] && [ -n "$ctx_size" ]; then
    # Format large numbers with 'k' suffix for readability
    used_k=$(echo "$total_input" | awk '{ printf "%.0fk", $1/1000 }')
    total_k=$(echo "$ctx_size" | awk '{ printf "%.0fk", $1/1000 }')
    parts+=("$(printf "󰍛 ${ctx_color}%s%%${RESET} ${RESET}(%s/%s)${RESET}" "$used_int" "$used_k" "$total_k")")
  else
    parts+=("$(printf "󰍛 ${ctx_color}%s%%${RESET}" "$used_int")")
  fi
fi

# Join with separator
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="$result $(printf '\033[2m|\033[0m') $part"
  fi
done

printf "%b\n" "$result"
