{ writeShellApplication }:

# Shows zombie (defunct) processes grouped by their parent.
# Zombies cannot be killed directly; kill or restart the parent to reap them.
writeShellApplication {
  name = "zombies";
  text = ''
    zombies=$(ps -axo pid,ppid,stat | awk 'NR > 1 && $3 ~ /^Z/ {print $1, $2}')
    count=$(printf '%s\n' "$zombies" | grep -c . || true)

    echo "Zombie processes: $count"
    [ "$count" -eq 0 ] && exit 0

    echo
    printf '%s\n' "$zombies" | awk '{print $2}' | sort | uniq -c | sort -rn |
      while read -r n ppid; do
        info=$(ps -o etime=,command= -p "$ppid" 2>/dev/null | cut -c1-160)
        printf '%4d zombies <- parent %d (up %s)\n' "$n" "$ppid" "''${info:-<gone>}"
      done

    echo
    echo "Tip: kill the parent to reap its zombies, e.g. kill <PPID>"
  '';
}
