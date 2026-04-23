#!/bin/bash
set -euo pipefail

pnpm create astro@latest "$@" --add react --add tailwind --add sitemap

# Find project dir from first non-flag arg
dir=""
for arg in "$@"; do
  [[ "$arg" != --* ]] && dir="$arg" && break
done

# Bail if user passed no dir or pnpm create didn't produce one
[ -z "$dir" ] || [ ! -d "$dir" ] && exit 0

cd "$dir"

# Inject ClientRouter into Layout.astro
layout="src/layouts/Layout.astro"
if [ -f "$layout" ]; then
  sed -i '' '1a\
import { ClientRouter } from "astro:transitions";
' "$layout"
  sed -i '' 's|</head>|  <ClientRouter />\n</head>|' "$layout"
  echo "  ✓ ClientRouter added to $layout"
fi

# Git: pnpm create astro may have init'd already (--git prompt). Idempotent.
if [ ! -d ".git" ]; then
  git init -q
fi
git add -A
git diff --cached --quiet || git commit -q -m "feat: scaffold $dir astro project"
echo "  ✓ Initial commit"

# Private GitHub repo + push main
gh repo create "$dir" --private --source=. --push
echo "  ✓ Private GitHub repo created"

# Production branch
git checkout -q -b production
git push -q -u origin production
git checkout -q main
echo "  ✓ Production branch created"

echo ""
echo "Done! $dir is ready."
echo "  GitHub: $(gh repo view --json url -q .url)"
echo "  Branches: main, production"
