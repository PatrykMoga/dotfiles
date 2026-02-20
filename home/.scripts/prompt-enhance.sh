#!/bin/bash
touch "/tmp/.prompt-${1:-enhance}-signal"
tmux send-keys C-e
