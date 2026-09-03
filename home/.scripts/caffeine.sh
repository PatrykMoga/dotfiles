#!/bin/bash
# Keep the Mac awake, lid open or closed. Toggled from tmux (prefix + C); while
# active the left status bar swaps its apple for a red 􀸙.
#
#   caffeinate -disu        blocks display/disk/idle/user-idle sleep
#   pmset disablesleep 1    blocks clamshell sleep — caffeinate can't do this one,
#                           and it needs root. Passwordless via /etc/sudoers.d/caffeine:
#
#     patrykmoga ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1
#
#   Install (stow only manages ~, so this file does not travel with the repo):
#     sudo install -m 0440 -o root -g wheel <file> /etc/sudoers.d/caffeine
#
#   ./caffeine.sh toggle    start if off, stop if on (prompts for sudo)
#   ./caffeine.sh sync      point @caffeine at the real state
#   ./caffeine.sh watch     lid watcher (started by toggle, exits when caffeine does)
set -u

# Match our exact invocation, not any caffeinate: other tools (Claude Code among
# them) run their own short-lived `caffeinate -i -t N` we must neither count nor kill.
FLAGS='-disu'

# pmset is the source of truth, not the caffeinate process: `disablesleep` is a
# system setting that outlives a logout, while caffeinate dies with the session.
# Reading the process instead would show "off" on a Mac that still can't sleep.
is_on() { pmset -g | grep -qE 'SleepDisabled[[:space:]]+1'; }

lid_closed() { ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes'; }

# The status bar reads a tmux option rather than shelling out every refresh.
sync_state() {
  if is_on; then tmux set -g @caffeine on; else tmux set -gu @caffeine; fi
  tmux refresh-client -S
} 2>/dev/null

# Passwordless via the sudoers rule above; falls back to sudo's own prompt on a
# machine where the rule is not installed yet.
set_disablesleep() { sudo /usr/bin/pmset -a disablesleep "$1"; }

case "${1:-sync}" in
  --selftest)
    fail=0
    check() { [ "$2" = "$3" ] && echo "ok   $1" || { echo "FAIL $1: want '$3', got '$2'"; fail=1; }; }
    # lid_closed must give a definite answer, not fail open
    lid_closed; lid=$?
    check "lid state readable" "$([ $lid -le 1 ] && echo yes)" "yes"
    exit "$fail"
    ;;
  sync)
    sync_state
    ;;
  watch)
    # A lid close with sleep disabled fires neither a sleep nor a display-sleep
    # event, so macOS's "lock immediately" rule never runs. Firing the display-off
    # event by hand puts us back on the normal path: real lock screen, session and
    # every process left running (a logout would kill the work caffeine protects).
    was_closed=false
    while is_on; do
      if lid_closed; then
        $was_closed || pmset displaysleepnow
        was_closed=true
      else
        was_closed=false
      fi
      sleep 2
    done
    ;;
  toggle)
    if is_on; then
      # sudo first: a cancelled prompt leaves the machine exactly as it was
      set_disablesleep 0 || exit 1
      pkill -xf "caffeinate $FLAGS"
      msg='􀸙  caffeine off — sleep re-enabled'
    else
      set_disablesleep 1 || exit 1
      nohup caffeinate $FLAGS >/dev/null 2>&1 &
      pgrep -f "caffeine.sh watch" >/dev/null || nohup "$0" watch >/dev/null 2>&1 &
      disown -a 2>/dev/null
      msg='􀸙  caffeine on — awake with the lid closed, locks when you shut it'
    fi
    sync_state
    tmux display-message "$msg" 2>/dev/null
    ;;
  *)
    echo "usage: ${0##*/} [toggle|sync|watch]" >&2
    exit 2
    ;;
esac
