#!/bin/bash
# Render statusline-command.sh against a set of fixture payloads so every visual
# state can be eyeballed at once. Docs describe this mock-input approach:
# https://code.claude.com/docs/en/statusline ("Test with mock input")
#
#   ./statusline-preview.sh            # render every fixture
#   ./statusline-preview.sh context    # only fixtures whose name matches "context"
#   ./statusline-preview.sh --list     # list fixture names
#
# Plan-usage (5h / 7d / per-model quota) lives in the tmux status bar now —
# check it with `~/.scripts/claude-usage.sh --selftest`, not here.

set -u

STATUSLINE="${STATUSLINE:-$HOME/.claude/statusline-command.sh}"
[ -x "$STATUSLINE" ] || { echo "not executable: $STATUSLINE" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Payload builders
# ---------------------------------------------------------------------------

# usage_json <total_tokens> — context_window.current_usage, or "null"
usage_json() {
  [ "$1" = "null" ] && { echo null; return; }
  echo "{\"input_tokens\":$1,\"output_tokens\":0,\"cache_creation_input_tokens\":0,\"cache_read_input_tokens\":0}"
}

# payload <tokens|null> [context_window_size]
payload() {
  local usage size
  usage=$(usage_json "$1")
  size="${2:-200000}"
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
  "exceeds_200k_tokens": false
}
JSON
}

# ---------------------------------------------------------------------------
# Fixtures: name | tokens | size
# ---------------------------------------------------------------------------

FIXTURES=(
  "fresh session|null|200000"
  "typical early session|12000|200000"
  "mid session|90000|200000"
  "context nearly full|190000|200000"
  "1M context window|180000|1000000"
  "gauge 0% (empty track)|0|200000"
  "gauge 25%|50000|200000"
  "gauge 50%|100000|200000"
  "gauge 75%|150000|200000"
  "gauge 100% (full)|200000|200000"
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
  IFS='|' read -r name tokens size <<< "$fixture"
  [ -n "$filter" ] && [[ "$name" != *"$filter"* ]] && continue
  shown=$((shown + 1))

  printf '\033[38;2;135;133;128m%s\033[0m\n' "$name"
  printf '  '
  payload "$tokens" "$size" | bash "$STATUSLINE"
  printf '\n'
done

if [ "$shown" -eq 0 ]; then
  echo "no fixtures matched: $filter" >&2
  exit 1
fi
