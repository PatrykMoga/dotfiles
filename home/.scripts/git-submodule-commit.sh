#!/usr/bin/env bash
set -euo pipefail

msg="${1:-}"
push=false

if [[ -z "$msg" ]]; then
  echo "Usage: git-submodule-commit.sh \"<conventional commit message>\" [--push]" >&2
  exit 1
fi

if [[ "${2:-}" == "--push" ]]; then
  push=true
fi

committed_any=false
committed_subs=()

while IFS= read -r sub_path; do
  [[ -z "$sub_path" ]] && continue

  if git -C "$sub_path" diff --cached --quiet 2>/dev/null; then
    continue
  fi

  echo "Committing submodule: $sub_path"
  git -C "$sub_path" commit -m "$msg"

  git add "$sub_path"

  # Build parent commit message
  sub_name="$(basename "$sub_path")"
  # Strip conventional commit prefix: handles feat:, feat(scope):, feat!:, feat(scope)!:
  description="$(echo "$msg" | sed 's/^[^:]*: //')"

  if [[ -n "$description" ]]; then
    parent_msg="chore: update ${sub_name} submodule with ${description}"
  else
    parent_msg="chore: update ${sub_name} submodule"
  fi

  echo "Committing parent: $parent_msg"
  git commit -m "$parent_msg"

  committed_subs+=("$sub_path")
  committed_any=true
done < <(git submodule status | awk '{print $2}')

if [[ "$committed_any" == false ]]; then
  echo "No submodules with staged changes found." >&2
  exit 1
fi

if [[ "$push" == true ]]; then
  for sub_path in "${committed_subs[@]}"; do
    echo "Pushing submodule: $sub_path"
    git -C "$sub_path" push
  done
  echo "Pushing parent"
  git push
fi
