#!/bin/bash
# Keep the Mac awake, lid open or closed. Toggled from tmux (prefix + C); while
# active the left status bar swaps its apple for a red 􀸙.
#
#   caffeinate -disu        blocks display/disk/idle/user-idle sleep
#   pmset disablesleep 1    blocks clamshell sleep — caffeinate can't do this one,
#                           and it needs root, hence the password prompt
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

# sudo owns the tty when it prompts, so ESC would just land in its password
# buffer. Read the password here instead, where ESC can mean "abort".
read_password() {
  local pw='' ch rest
  printf 'Password (ESC to cancel): ' >&2
  while IFS= read -rsn1 ch; do
    case "$ch" in
      '')             break ;;                       # Enter
      $'\e')          read -rsn8 -t 0.01 rest && continue   # arrow key, not a bare ESC
                      printf '\n' >&2; return 1 ;;
      $'\177'|$'\b')  pw="${pw%?}" ;;
      *)              pw+="$ch" ;;
    esac
  done
  printf '\n' >&2
  printf '%s' "$pw"
}

# Reuse an unexpired sudo timestamp before asking for anything.
set_disablesleep() {
  sudo -n /usr/bin/pmset -a disablesleep "$1" 2>/dev/null && return 0
  local pw
  pw=$(read_password) || return 1
  printf '%s\n' "$pw" | sudo -S -p '' /usr/bin/pmset -a disablesleep "$1" 2>/dev/null
}

case "${1:-sync}" in
  --selftest)
    fail=0
    check() { [ "$2" = "$3" ] && echo "ok   $1" || { echo "FAIL $1: want '$3', got '$2'"; fail=1; }; }
    check "plain password" "$(printf 'hunter2\n' | read_password 2>/dev/null)" "hunter2"
    check "backspace"      "$(printf 'abc\177\n' | read_password 2>/dev/null)" "ab"
    printf '\033' | read_password >/dev/null 2>&1
    check "bare ESC aborts" "$?" "1"
    printf '\033[Ax\n' | read_password >/dev/null 2>&1
    check "arrow key does not abort" "$?" "0"
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
