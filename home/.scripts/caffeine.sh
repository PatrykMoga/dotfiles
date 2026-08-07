#!/bin/bash
# Keep the Mac awake, lid open or closed. Toggled from tmux (prefix + C), shown
# in the status bar as a red 􀸙 while active.
#
#   caffeinate -disu        blocks display/disk/idle/user-idle sleep
#   pmset disablesleep 1    blocks clamshell sleep — caffeinate can't do this one,
#                           and it needs root, hence the popup password prompt
#
#   ./caffeine.sh toggle    start if off, stop if on
#   ./caffeine.sh status    tmux status segment (empty when off)
set -u

ICON='#[fg=#d14d41]􀸙  '   # cup.and.saucer.fill, Flexoki red

# Match our exact invocation, not any caffeinate: other tools (Claude Code among
# them) run their own short-lived `caffeinate -i -t N` we must neither count nor kill.
FLAGS='-disu'

is_on() { pgrep -xf "caffeinate $FLAGS" >/dev/null 2>&1; }

case "${1:-status}" in
  status)
    is_on && printf '%s' "$ICON"
    ;;
  toggle)
    if is_on; then
      # sudo first: a cancelled password leaves the machine exactly as it was
      sudo pmset -a disablesleep 0 || exit 1
      pkill -xf "caffeinate $FLAGS"
      msg='􀸙  caffeine off — sleep re-enabled'
    else
      sudo pmset -a disablesleep 1 || exit 1
      nohup caffeinate $FLAGS >/dev/null 2>&1 &
      disown 2>/dev/null
      msg='􀸙  caffeine on — awake with the lid closed'
    fi
    tmux refresh-client -S 2>/dev/null
    tmux display-message "$msg" 2>/dev/null
    ;;
  *)
    echo "usage: ${0##*/} [toggle|status]" >&2
    exit 2
    ;;
esac
