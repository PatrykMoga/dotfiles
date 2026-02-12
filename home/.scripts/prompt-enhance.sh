#!/bin/bash

input=$(pbpaste)
if [ -z "$input" ]; then
  tmux display-message "Clipboard empty — copy your prompt first"
  exit 0
fi

tmux display-message "Enhancing prompt..."

# Enhance via Claude skill (stdin pipe avoids shell escaping issues)
enhanced=$(echo "$input" | claude -p "/prompt-enhance" --model haiku 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$enhanced" ]; then
  tmux display-message "Enhancement failed"
  exit 1
fi

# Delete original text from input (random-name backspace pattern)
len=${#input}
tmux send-keys $(printf "BSpace %.0s" $(seq 1 $len))

# Paste enhanced text via tmux buffer (bracketed paste = safe multi-line)
printf '%s' "$enhanced" | tmux load-buffer -
tmux paste-buffer

tmux display-message "Prompt enhanced ✓"
