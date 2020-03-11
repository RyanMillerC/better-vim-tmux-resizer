#!/usr/bin/env bash

# If you use vim-tmux-navigator, you don't need to put this line twice
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# Edit values if you use custom resize_count variables
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "resize-pane -L 10"
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "resize-pane -D 5"
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "resize-pane -U 5"
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "resize-pane -R 10"

tmux bind-key -T copy-mode-vi M-h resize-pane -L 10
tmux bind-key -T copy-mode-vi M-j resize-pane -D 5
tmux bind-key -T copy-mode-vi M-k resize-pane -U 5
tmux bind-key -T copy-mode-vi M-l resize-pane -R 10
