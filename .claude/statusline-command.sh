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
CONTEXT_USAGE=$(echo "$input" | jq '.context_window.current_usage')
COST=$(get_cost)
DURATION=$(get_duration)
LINES_ADDED=$(get_lines_added)
LINES_REMOVED=$(get_lines_removed)

STATUS_LINE="􂮢  $MODEL | 􀈕  ${CURRENT_DIR##*/}"

# Show git branch if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        STATUS_LINE+=" | 􀙠  $BRANCH"
    fi
fi

# Show lines added and removed
if [ "$LINES_ADDED" != "null" ] || [ "$LINES_REMOVED" != "null"]; then
    STATUS_LINE+=" | 􀄬  $LINES_ADDED/$LINES_REMOVED"
fi

# Show current context usage
if [ "$CONTEXT_USAGE" != "null" ]; then
    # Calculate current context from current_usage fields
    CURRENT_TOKENS=$(echo "$CONTEXT_USAGE" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    CURRENT_CONTEXT_USAGE=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
    STATUS_LINE+=" | 􀫦  $CURRENT_CONTEXT_USAGE% "
else
    STATUS_LINE+=" | 􀫦  0% "
fi

# Format status line
echo "$STATUS_LINE"
