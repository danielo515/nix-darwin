# Watches for zombie (<defunct>) process accumulation and notifies before it
# exhausts kern.maxprocperuid and breaks fork() system-wide (seen with leaky
# Raycast extensions and oxlint's LSP under Devin/Conductor).
{pkgs, ...}: let
  absThreshold = 50; # notify if total zombies reach this
  deltaThreshold = 20; # ...or jump by this much since the last check
  debounceSecs = 1800; # don't re-notify more often than this while still elevated

  checkScript = pkgs.writeShellScript "zombie-watch-check" ''
    set -euo pipefail
    STATE_DIR="$HOME/.cache/zombie-watch"
    STATE_FILE="$STATE_DIR/last_count"
    DEBOUNCE_FILE="$STATE_DIR/last_notify"
    mkdir -p "$STATE_DIR"

    total=$(/bin/ps -eo stat | /usr/bin/awk '$1 ~ /Z/' | /usr/bin/wc -l | /usr/bin/tr -d ' ')
    prev=0
    [ -f "$STATE_FILE" ] && prev=$(cat "$STATE_FILE")
    echo "$total" > "$STATE_FILE"

    delta=$((total - prev))
    now=$(/bin/date +%s)

    if [ "$total" -ge ${toString absThreshold} ] || [ "$delta" -ge ${toString deltaThreshold} ]; then
      last_notify=0
      [ -f "$DEBOUNCE_FILE" ] && last_notify=$(cat "$DEBOUNCE_FILE")
      if [ $((now - last_notify)) -ge ${toString debounceSecs} ]; then
        top=$(/bin/ps -eo ppid,stat | /usr/bin/awk '$2 ~ /Z/ {print $1}' | /usr/bin/sort | /usr/bin/uniq -c | /usr/bin/sort -rn | /usr/bin/head -1)
        top_pid=$(echo "$top" | /usr/bin/awk '{print $2}')
        top_count=$(echo "$top" | /usr/bin/awk '{print $1}')
        top_comm=$(/bin/ps -p "''${top_pid:-0}" -o comm= 2>/dev/null || echo unknown)
        /usr/bin/osascript -e "display notification \"Total: $total zombies (delta $delta). Top offender: $top_comm (pid $top_pid, $top_count zombies).\" with title \"Zombie processes rising\" sound name \"Basso\""
        echo "$now" > "$DEBOUNCE_FILE"
      fi
    fi
  '';
in {
  launchd.agents.zombie-watch = {
    enable = true;
    config = {
      ProgramArguments = ["${checkScript}"];
      StartInterval = 300;
      RunAtLoad = true;
      StandardOutPath = "/tmp/zombie-watch.log";
      StandardErrorPath = "/tmp/zombie-watch.err";
    };
  };
}
