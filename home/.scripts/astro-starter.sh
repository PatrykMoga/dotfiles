#!/bin/bash

pnpm create astro@latest "$@" --add react --add tailwind --add sitemap

# Find the project directory from the first non-flag argument
dir=""
for arg in "$@"; do
  [[ "$arg" != --* ]] && dir="$arg" && break
done

# Inject ClientRouter into Layout.astro if project dir was provided
layout="$dir/src/layouts/Layout.astro"
if [ -n "$dir" ] && [ -f "$layout" ]; then
  # Add import to frontmatter (after line 1 = opening ---)
  sed -i '' '1a\
import { ClientRouter } from "astro:transitions";
' "$layout"
  # Add component to <head>
  sed -i '' 's|</head>|  <ClientRouter />\n</head>|' "$layout"
  echo ""
  echo "Added <ClientRouter /> to $layout"
else
  echo ""
  echo "Note: Add view transitions manually to your layout:"
  echo '  import { ClientRouter } from "astro:transitions";'
  echo '  <ClientRouter />  (inside <head>)'
fi
