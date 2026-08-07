#!/bin/bash
# Claude plan usage for the tmux status bar: "􀐱  24% 45m · 64% 13h · 93% 13h Fable"
# (5h window · 7d window · per-model window, each with time until reset).
#
# Everything comes from the OAuth usage endpoint, not the Claude Code statusline
# payload — one cache, one bar, so N claude panes can't disagree with each other.
#
#   ./claude-usage.sh              # print the tmux-styled segment
#   ./claude-usage.sh --selftest   # assert rendering against fixtures
set -u

CACHE="${CLAUDE_USAGE_CACHE:-$HOME/.claude/.usage.json}"
TTL=60

GREEN='#879a39'; YELLOW='#d0a215'; RED='#d14d41'; DIM='#6f6e69'

# Seconds until an ISO-8601 (or epoch) timestamp, humanized: "6d2h", "3h59m", "12m"
time_left() {
  local ts="$1" target now diff d h m
  { [ -z "$ts" ] || [ "$ts" = "null" ]; } && return 1
  if [[ "$ts" =~ ^[0-9]+$ ]]; then
    target="$ts"
  else
    # BSD date: strip fractional seconds and the trailing zone marker
    ts="${ts%.*}"; ts="${ts%Z}"
    target=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${ts%%+*}" "+%s" 2>/dev/null) || return 1
  fi
  now=$(date "+%s")
  diff=$((target - now))
  [ "$diff" -le 0 ] && { echo "now"; return 0; }
  d=$((diff / 86400)); h=$(((diff % 86400) / 3600)); m=$(((diff % 3600) / 60))
  # no separator: the unit letters already delimit the numbers, so a space is wasted width
  if   [ "$d" -gt 0 ]; then echo "${d}d${h}h"
  elif [ "$h" -gt 0 ]; then echo "${h}h${m}m"
  else                      echo "${m}m"
  fi
}

pct_color() {
  if   [ "$1" -ge 90 ]; then echo "$RED"
  elif [ "$1" -ge 75 ]; then echo "$YELLOW"
  else                       echo "$GREEN"
  fi
}

if [ "${1:-}" = "--selftest" ]; then
  fail=0
  check() { # name expected-substring output
    if [[ "$3" == *"$2"* ]]; then echo "ok   $1"
    else echo "FAIL $1: want '$2' in '$3'"; fail=1
    fi
  }
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  soon=$(date -u -r $(( $(date +%s) + 2700 )) '+%Y-%m-%dT%H:%M:%S.000000+00:00')
  week=$(date -u -r $(( $(date +%s) + 259200 )) '+%Y-%m-%dT%H:%M:%S.000000+00:00')

  cat > "$tmp/full.json" <<JSON
{"five_hour":{"utilization":24.0,"resets_at":"$soon"},
 "seven_day":{"utilization":91.0,"resets_at":"$week"},
 "limits":[{"kind":"weekly_scoped","percent":80,"resets_at":"$week",
            "scope":{"model":{"display_name":"Fable"}}}]}
JSON
  out=$(CLAUDE_USAGE_CACHE="$tmp/full.json" bash "$0")
  check "5h percent"     "24%"      "$out"
  check "5h countdown"   "45m"      "$out"
  check "7d countdown"   "3d0h"     "$out"
  check "scoped label"   "Fable"    "$out"
  check "green under 75" "$GREEN]24%"  "$out"
  check "red at 90+"     "$RED]91%"    "$out"
  check "yellow at 75+"  "$YELLOW]80%" "$out"

  echo '{"five_hour":{"utilization":null},"limits":[]}' > "$tmp/empty.json"
  out=$(CLAUDE_USAGE_CACHE="$tmp/empty.json" bash "$0")
  check "no data prints nothing" "" "$out"
  [ -z "$out" ] || { echo "FAIL empty fixture rendered: '$out'"; fail=1; }

  exit "$fail"
fi

# Refresh in the background when stale. Touch first: the mtime bump makes every
# other pane's copy of this script see a fresh cache, so only one curl goes out.
if [ -z "${CLAUDE_USAGE_CACHE:-}" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0) ))
  if [ "$age" -gt "$TTL" ]; then
    touch "$CACHE"
    {
      token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
                | jq -r '.claudeAiOauth.accessToken // empty')
      if [ -n "$token" ]; then
        tmp=$(mktemp) || exit
        curl -s --max-time 5 https://api.anthropic.com/api/oauth/usage \
          -H "Authorization: Bearer $token" \
          -H "anthropic-beta: oauth-2025-04-20" \
          -H "User-Agent: claude-code/2.1.0" \
          -o "$tmp" \
          && jq -e . "$tmp" >/dev/null 2>&1 \
          && mv "$tmp" "$CACHE"
        rm -f "$tmp"
      fi
    } >/dev/null 2>&1 &
    disown 2>/dev/null
  fi
fi

[ -s "$CACHE" ] || exit 0

# percent \t resets_at \t label — one line per window, in display order
ROWS=$(jq -r '
  def row(p; r; l): if (p | type) == "number" then "\(p)\t\(r // "")\t\(l)" else empty end;
  row(.five_hour.utilization;  .five_hour.resets_at;  ""),
  row(.seven_day.utilization;  .seven_day.resets_at;  ""),
  ((.limits // [])
   | map(select(.kind == "weekly_scoped" and (.percent | type) == "number"))
   | first
   | if . then row(.percent; .resets_at; (.scope.model.display_name // "model")) else empty end)
' "$CACHE" 2>/dev/null)

[ -n "$ROWS" ] || exit 0

SEGMENT=""; ICON_COLOR=""
while IFS=$'\t' read -r pct resets label; do
  [ -n "$pct" ] || continue
  used=$(echo "$pct" | awk '{printf "%.0f", $1}')
  color=$(pct_color "$used")
  [ -n "$ICON_COLOR" ] || ICON_COLOR="$color"   # the clock mirrors the 5h window
  reset_in=$(time_left "$resets")
  SEGMENT+="${SEGMENT:+ #[fg=$DIM]· }#[fg=$color]${used}%${reset_in:+ #[fg=$DIM]$reset_in}${label:+ #[fg=$DIM]$label}"
done <<< "$ROWS"

printf '#[fg=%s]􀐱  %s' "$ICON_COLOR" "$SEGMENT"
