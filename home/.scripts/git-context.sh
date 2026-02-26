#!/usr/bin/env bash
set -euo pipefail

# Check if anything is staged in the main repo
main_staged=true
git diff --cached --quiet && main_staged=false

# Check if anything is staged in submodules (if .gitmodules exists)
sub_staged=false
if [[ -f ".gitmodules" ]]; then
  while IFS= read -r sub_path; do
    if [[ -n "$sub_path" ]] && ! git -C "$sub_path" diff --cached --quiet 2>/dev/null; then
      sub_staged=true
      break
    fi
  done < <(git submodule status | awk '{print $2}')
fi

if [[ "$main_staged" == false && "$sub_staged" == false ]]; then
  echo "Nothing staged. Run 'git add' first." >&2
  exit 1
fi

echo "=== STATUS ==="
git status

echo ""
echo "=== STAGED DIFF ==="
git diff --cached

echo ""
echo "=== RECENT COMMITS ==="
git log --oneline -10

if [[ -f ".gitmodules" ]]; then
  echo ""
  echo "=== SUBMODULES ==="
  git submodule status

  while IFS= read -r sub_path; do
    if [[ -n "$sub_path" ]] && ! git -C "$sub_path" diff --cached --quiet 2>/dev/null; then
      echo ""
      echo "--- $sub_path staged diff ---"
      git -C "$sub_path" diff --cached
    fi
  done < <(git submodule status | awk '{print $2}')
fi
