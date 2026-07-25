#!/bin/bash
# Render statusline-command.sh against a set of fixture payloads so every visual
# state can be eyeballed at once. Docs describe this mock-input approach:
# https://code.claude.com/docs/en/statusline ("Test with mock input")
#
#   ./statusline-preview.sh            # render every fixture
#   ./statusline-preview.sh context    # only fixtures whose name matches "context"
#   ./statusline-preview.sh --list     # list fixture names
#
# Fable note: the script reads its Fable quota from a cache file, not stdin, so
# these fixtures point FABLE_CACHE at a temp file we control. That keeps the
# preview hermetic — no keychain access, no network, no dependence on real usage.

set -u

STATUSLINE="${STATUSLINE:-$HOME/.claude/statusline-command.sh}"
[ -x "$STATUSLINE" ] || { echo "not executable: $STATUSLINE" >&2; exit 1; }

TMPDIR_RUN=$(mktemp -d) || exit 1
trap 'rm -rf "$TMPDIR_RUN"' EXIT

# ---------------------------------------------------------------------------
# Payload builders
# ---------------------------------------------------------------------------

# usage_json <total_tokens> — context_window.current_usage, or "null"
usage_json() {
  [ "$1" = "null" ] && { echo null; return; }
  echo "{\"input_tokens\":$1,\"output_tokens\":0,\"cache_creation_input_tokens\":0,\"cache_read_input_tokens\":0}"
}

# payload <tokens|null> <rate_limits_json|""> [context_window_size]
payload() {
  local usage rl size rl_field=""
  usage=$(usage_json "$1")
  rl="$2"
  size="${3:-200000}"
  # built outside the heredoc: quoting a key inside ${var:+...} breaks the expansion
  [ -n "$rl" ] && rl_field=",
  \"rate_limits\": $rl"
  cat <<JSON
{
  "cwd": "/Users/me/Developer/dotfiles",
  "session_id": "preview-session",
  "version": "2.1.220",
  "model": { "id": "claude-opus-5", "display_name": "Opus 5" },
  "workspace": {
    "current_dir": "/Users/me/Developer/dotfiles",
    "project_dir": "/Users/me/Developer/dotfiles",
    "added_dirs": []
  },
  "output_style": { "name": "default" },
  "cost": {
    "total_cost_usd": 0.42,
    "total_duration_ms": 45000,
    "total_api_duration_ms": 2300,
    "total_lines_added": 43,
    "total_lines_removed": 4
  },
  "context_window": {
    "total_input_tokens": 0,
    "total_output_tokens": 0,
    "context_window_size": $size,
    "current_usage": $usage
  },
  "exceeds_200k_tokens": false$rl_field
}
JSON
}

# Windows expressed relative to now so countdowns stay realistic every run.
now=$(date +%s)
in_2h=$((now + 7200))
in_4h=$((now + 14400))
in_6d=$((now + 518400))
past=$((now - 3600))

# rl <5h_pct> <5h_reset> <7d_pct> <7d_reset> — "-" omits a window entirely
rl() {
  local parts=""
  [ "$1" != "-" ] && parts="\"five_hour\":{\"used_percentage\":$1,\"resets_at\":$2}"
  [ "$3" != "-" ] && parts="${parts:+$parts,}\"seven_day\":{\"used_percentage\":$3,\"resets_at\":$4}"
  [ -z "$parts" ] && { echo ""; return; }
  echo "{$parts}"
}

# fable_cache <percent|-> <resets_at_json>
fable_cache() {
  local f="$TMPDIR_RUN/fable.json"
  if [ "$1" = "-" ]; then
    echo '{"limits":[]}' > "$f"
  else
    cat > "$f" <<JSON
{"limits":[{"kind":"weekly_scoped","group":"weekly","percent":$1,"resets_at":$2,
  "scope":{"model":{"id":null,"display_name":"Fable"}},"is_active":false}]}
JSON
  fi
  echo "$f"
}

# ---------------------------------------------------------------------------
# Fixtures: name | tokens | rate_limits | fable_pct | fable_reset | size
# ---------------------------------------------------------------------------

FIXTURES=(
  "fresh session (no rate_limits yet)|null||-|null|200000"
  "typical early session|12000|$(rl 4 $in_4h 10 $in_6d)|1|$in_6d|200000"
  "mid session|90000|$(rl 45 $in_2h 38 $in_6d)|22|$in_6d|200000"
  "context nearly full|190000|$(rl 60 $in_2h 44 $in_6d)|30|$in_6d|200000"
  "5h window warning (80%)|50000|$(rl 80 $in_2h 40 $in_6d)|30|$in_6d|200000"
  "5h window critical (95%)|50000|$(rl 95 $in_2h 55 $in_6d)|30|$in_6d|200000"
  "all windows critical|170000|$(rl 97 $in_2h 93 $in_6d)|95|$in_6d|200000"
  "5h window absent (not started)|12000|$(rl - - 10 $in_6d)|1|$in_6d|200000"
  "7d window absent|12000|$(rl 4 $in_4h - -)|1|$in_6d|200000"
  "no fable data|12000|$(rl 4 $in_4h 10 $in_6d)|-|null|200000"
  "fable with no reset time|12000|$(rl 4 $in_4h 10 $in_6d)|0|null|200000"
  "reset time in the past|12000|$(rl 88 $past 10 $in_6d)|1|$in_6d|200000"
  "ISO 8601 resets_at (live API form)|12000|{\"five_hour\":{\"used_percentage\":4.2,\"resets_at\":\"$(date -u -r $in_4h '+%Y-%m-%dT%H:%M:%S.000000+00:00')\"},\"seven_day\":{\"used_percentage\":10.7,\"resets_at\":\"$(date -u -r $in_6d '+%Y-%m-%dT%H:%M:%SZ')\"}}|1|$in_6d|200000"
  "1M context window|180000|$(rl 4 $in_4h 10 $in_6d)|1|$in_6d|1000000"
  "everything empty|null||-|null|200000"
)

# ---------------------------------------------------------------------------
# Render
# ---------------------------------------------------------------------------

filter="${1:-}"
if [ "$filter" = "--list" ]; then
  for f in "${FIXTURES[@]}"; do echo "${f%%|*}"; done
  exit 0
fi

printf '\n\033[1mstatusline preview\033[0m  \033[38;2;135;133;128m%s\033[0m\n\n' "$STATUSLINE"

shown=0
for fixture in "${FIXTURES[@]}"; do
  IFS='|' read -r name tokens rate fpct freset size <<< "$fixture"
  [ -n "$filter" ] && [[ "$name" != *"$filter"* ]] && continue
  shown=$((shown + 1))

  cache=$(fable_cache "$fpct" "$freset")
  printf '\033[38;2;135;133;128m%s\033[0m\n' "$name"
  printf '  '
  payload "$tokens" "$rate" "$size" \
    | FABLE_CACHE_OVERRIDE="$cache" ANTHROPIC_API_KEY="" bash "$STATUSLINE"
  printf '\n'
done

if [ "$shown" -eq 0 ]; then
  echo "no fixtures matched: $filter" >&2
  exit 1
fi
