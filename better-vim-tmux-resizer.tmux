#!/usr/bin/env bash

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# Edit values if you use custom resize_count variables
tmux bind-key -n M-h if-shell "$is_vim" "send-keys M-h"  "resize-pane -L 10"
tmux bind-key -n M-j if-shell "$is_vim" "send-keys M-j"  "resize-pane -D 5"
tmux bind-key -n M-k if-shell "$is_vim" "send-keys M-k"  "resize-pane -U 5"
tmux bind-key -n M-l if-shell "$is_vim" "send-keys M-l"  "resize-pane -R 10"

tmux bind-key -T copy-mode-vi M-h resize-pane -L 10
tmux bind-key -T copy-mode-vi M-j resize-pane -D 5
tmux bind-key -T copy-mode-vi M-k resize-pane -U 5
tmux bind-key -T copy-mode-vi M-l resize-pane -R 10
