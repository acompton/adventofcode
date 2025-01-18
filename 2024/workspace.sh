#!/bin/bash

SESSION="adventofcode-2024"
SESSION_EXISTS=$(tmux list-sessions 2>/dev/null | grep SESSION)

cd "$(dirname "$0")"

if [ "$SESSION_EXISTS" = "" ]; then
  tmux new-session -d -s $SESSION
  tmux rename-window -t 0 'AOC2024'
  tmux send-keys -t 'AOC2024' 'nvim' C-m

  tmux new-window -t $SESSION:1 -n 'Shell'
  tmux send-keys -t 'Shell' 'clear' C-m
fi

tmux attach-session -t $SESSION:0
