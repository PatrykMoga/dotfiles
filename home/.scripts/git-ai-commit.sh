#!/usr/bin/env bash
# Fast commit with an AI-written conventional message via a single-shot
# `claude -p` call (one round-trip, --strict-mcp-config). Replaces the old
# multi-turn `claude -p "/commit"` skill flow, which took ~30s; this is ~10s.
#
# Submodules: each submodule with staged changes gets its OWN one-shot AI
# message, then the parent pointer is bumped with a generic
# `chore: update <name> submodule`. The parent NEVER embeds the submodule's
# message — a submodule repo may be private while the parent is public, so its
# history must not leak into the parent.
#
# Commits only what is already staged (like the old skill). Stage first.
#
# Usage: git-ai-commit.sh [--push]
#   --push   also push committed repos (submodules first, then parent)
set -euo pipefail

push=false
[[ "${1:-}" == "--push" ]] && push=true

git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not a git repo." >&2; exit 1; }

# ai_message <git-dir-or-path> -> prints a one-line conventional commit message.
# Falls back to a generic message if claude -p fails or returns nothing.
ai_message() {
  local dir="$1" diff msg
  diff="$(git -C "$dir" diff --cached)"
  # `|| true` so a failed claude -p can't trip `set -e`/pipefail — the empty
  # check below falls back to a generic message.
  msg="$(printf '%s\n' "$diff" | CLAUDE_GIT_NESTED=1 claude -p \
    "Write ONE line: a Conventional Commits message (type(scope): summary) for this staged diff. Output only the message, no quotes, no prose, no body." \
    --strict-mcp-config --allowedTools "" 2>/dev/null \
    | grep -m1 -v '^[[:space:]]*$' | head -c 200 || true)"
  # Strip surrounding whitespace/backticks the model sometimes adds.
  msg="$(printf '%s' "$msg" | sed 's/^[[:space:]]*`*//; s/`*[[:space:]]*$//')"
  if [[ -z "$msg" ]]; then
    msg="chore: update $(basename "$(git -C "$dir" rev-parse --show-toplevel)")"
  fi
  printf '%s' "$msg"
}

committed_any=false
pushed_subs=()

# --- Submodules: AI message for the submodule, generic bump for the parent ---
# Two cases both result in a parent pointer bump:
#   1. The submodule has staged changes  -> commit them (AI message), then bump.
#   2. The submodule has no staged changes but the parent gitlink is stale
#      (its HEAD moved — e.g. committed by the auto-checkpoint hook or by hand)
#      -> just bump the parent pointer, no submodule commit.
if [[ -f ".gitmodules" ]]; then
  while IFS= read -r sub_path; do
    [[ -z "$sub_path" ]] && continue
    sub_name="$(basename "$sub_path")"

    if ! git -C "$sub_path" diff --cached --quiet 2>/dev/null; then
      # Case 1: staged work inside the submodule — commit it first.
      git -C "$sub_path" commit -q -m "$(ai_message "$sub_path")"
    elif git diff --quiet -- "$sub_path" 2>/dev/null; then
      # No staged submodule work AND the parent pointer is already up to date —
      # nothing to do for this submodule.
      continue
    fi

    # Bump the parent pointer (covers both cases 1 and 2).
    git add "$sub_path"
    git commit -q -m "chore: update ${sub_name} submodule"
    committed_any=true
    $push && pushed_subs+=("$sub_path")
  done < <(git submodule status | awk '{print $2}')
fi

# --- Main repo: AI message for remaining staged changes ----------------------
if ! git diff --cached --quiet; then
  git commit -q -m "$(ai_message .)"
  committed_any=true
fi

if [[ "$committed_any" == false ]]; then
  echo "Nothing staged. Run 'git add' first." >&2
  exit 1
fi

if [[ "$push" == true ]]; then
  for sub_path in "${pushed_subs[@]}"; do
    git -C "$sub_path" push
  done
  git push
fi

git log -1 --oneline
