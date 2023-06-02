#!/usr/bin/env bash

# $1: option
# $2: default value
tmux_get() {
    local value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

# Options
tmux_resizer_resize_count=$(tmux_get '@tmux_resizer_resize_count' '5')
tmux_resizer_vertical_resize_count=$(tmux_get '@tmux_resizer_vertical_resize_count' '5')

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# Edit values if you use custom resize_count variables
tmux bind-key -n M-h if-shell "$is_vim" "send-keys M-h"  "resize-pane -L $tmux_resizer_vertical_resize_count"
tmux bind-key -n M-j if-shell "$is_vim" "send-keys M-j"  "resize-pane -D $tmux_resizer_resize_count"
tmux bind-key -n M-k if-shell "$is_vim" "send-keys M-k"  "resize-pane -U $tmux_resizer_resize_count"
tmux bind-key -n M-l if-shell "$is_vim" "send-keys M-l"  "resize-pane -R $tmux_resizer_vertical_resize_count"

tmux bind-key -T copy-mode-vi M-h resize-pane -L $tmux_resizer_vertical_resize_count
tmux bind-key -T copy-mode-vi M-j resize-pane -D $tmux_resizer_resize_count
tmux bind-key -T copy-mode-vi M-k resize-pane -U $tmux_resizer_resize_count
tmux bind-key -T copy-mode-vi M-l resize-pane -R $tmux_resizer_vertical_resize_count
