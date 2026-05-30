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
# Works from the superproject root (bumps parent as a side effect) AND from
# inside a submodule (lazygit runs the command with cwd set to the submodule
# when one is selected — see the superproject block near the end).
#
# Commits only what is already staged (like the old skill). Stage first.
#
# Usage: git-ai-commit.sh [--push]
#   --push   also push committed repos (submodule first, then parent)
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

# --- Submodules (when run from the superproject) -----------------------------
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
      # Nothing staged and pointer current — nothing to do for this submodule.
      continue
    fi
    # else: case 2 (pointer stale only) — fall through to the bump.

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

# --- If we ran INSIDE a submodule, bump the parent pointer -------------------
# lazygit runs the custom command with cwd set to the SUBMODULE when a submodule
# is selected, so the block above never sees a parent. Walk up to the
# superproject and bump the gitlink with a generic message (privacy: never
# carries the submodule's own message into the parent). Runs even when nothing
# was staged here, so it also RECOVERS a stale pointer left by an earlier run
# that committed the submodule but didn't bump the parent.
super="$(git rev-parse --show-superproject-working-tree 2>/dev/null || true)"
if [[ -n "$super" ]]; then
  my_root="$(git rev-parse --show-toplevel)"
  sub_rel="${my_root#"$super"/}"          # e.g. home/.claude
  sub_name="$(basename "$sub_rel")"
  # Push the submodule's own remote FIRST so the parent pointer is reachable.
  if [[ "$push" == true && "$committed_any" == true ]]; then
    git push
  fi
  if ! git -C "$super" diff --quiet -- "$sub_rel" 2>/dev/null; then
    git -C "$super" add "$sub_rel"
    git -C "$super" commit -q -m "chore: update ${sub_name} submodule"
    $push && git -C "$super" push
    committed_any=true
  fi
  if [[ "$committed_any" == true ]]; then
    git log -1 --oneline
    exit 0
  fi
fi

if [[ "$committed_any" == false ]]; then
  echo "Nothing staged. Run 'git add' first." >&2
  exit 1
fi

# Normal (run-from-superproject) push path.
if [[ "$push" == true ]]; then
  for sub_path in "${pushed_subs[@]}"; do
    git -C "$sub_path" push
  done
  git push
fi

git log -1 --oneline
