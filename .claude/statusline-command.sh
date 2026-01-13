#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }
get_input_tokens() { echo "$input" | jq -r '.context_window.total_input_tokens'; }
get_output_tokens() { echo "$input" | jq -r '.context_window.total_output_tokens'; }
get_context_window_size() { echo "$input" | jq -r '.context_window.context_window_size'; }
get_context_current_usage() { echo "$input" | jq -r '.context_window.current_usage'; }

# Use the helpers
MODEL=$(get_model_name)
CURRENT_DIR=$(get_current_dir)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')
USAGE=$(echo "$input" | jq '.context_window.current_usage')

# Show git branch if in a git repo
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 􀙠  $BRANCH"
    fi
fi

# Show current usage
CURRENT_USAGE=""
if [ "$USAGE" != "null" ]; then
    # Calculate current context from current_usage fields
    CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    CURRENT_USAGE=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
else
    CURRENT_USAGE="0"
fi

# Format status line
echo "􂮢  $MODEL | 􀈕  ${CURRENT_DIR##*/}$GIT_BRANCH | 􁫏  $CURRENT_USAGE%"
