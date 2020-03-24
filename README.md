# (Better) Vim Tmux Resizer

> Resize tmux panes and Vim windows with ease.

This is a fork of [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
which allows resizing panes and windows instead of navigating between them. It is 100%
compatible with vim-tmux-navigator so you can have both installed and navigate/resize
with similar hotkeys.

**NOTE**: This requires tmux v1.8 or higher.

## Why not use [vim-tmux-resizer](https://github.com/melonmanchan/vim-tmux-resizer)?

Because this plugin allows for a seamless experience between tmux panes and Vim windows.
Vim-tmux-resizer doesn't pass resize bindings to tmux when inside a pane running Vim.
Better-vim-tmux-resizer gives more seamless control by enabling resizing tmux within a
pane running Vim. 

## Usage

This plugin provides the following mappings which allow you to resize Vim panes
and tmux splits seamlessly.

- `<meta-h>` => Left
- `<meta-j>` => Down
- `<meta-k>` => Up
- `<meta-l>` => Right

**NOTE:** You don't need to use your tmux `prefix` key sequence before using
the mappings.

If you want to use alternate key mappings, see the [configuration section
below](#configuration).

## Installation

### Vim

If you don't have a preferred installation method, I recommend using
[Plug](https://github.com/junegunn/vim-plug). Assuming you have Plug installed
and configured, the following steps will install the plugin:

Add the following line to your `~/.vimrc` file:

``` vim
Plug 'RyanMillerC/better-vim-tmux-resizer'
```

Then run:

```
:PlugInstall
```

### tmux

To configure the tmux side of this customization there are two options:

#### Add a snippet

Add the following to your `~/.tmux.conf` file:

``` tmux
# Smart pane resizing with awareness of Vim splits.
# See: https://github.com/RyanMillerC/better-vim-tmux-resizer
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# Edit values if you use custom resize_count variables
bind-key -n M-h if-shell "$is_vim" "send-keys M-h"  "resize-pane -L 10"
bind-key -n M-j if-shell "$is_vim" "send-keys M-j"  "resize-pane -D 5"
bind-key -n M-k if-shell "$is_vim" "send-keys M-k"  "resize-pane -U 5"
bind-key -n M-l if-shell "$is_vim" "send-keys M-l"  "resize-pane -R 10"

bind-key -T copy-mode-vi M-h resize-pane -L 10
bind-key -T copy-mode-vi M-j resize-pane -D 5
bind-key -T copy-mode-vi M-k resize-pane -U 5
bind-key -T copy-mode-vi M-l resize-pane -R 10
```

**NOTE:** If you use vim-tmux-navigator, you can omit the `is_vim` line since
it should already be in your `~/.tmux.conf` file.

#### TPM

If you'd prefer, you can use the Tmux Plugin Manager
([TPM](https://github.com/tmux-plugins/tpm)) instead of copying the snippet.
When using TPM, add the following lines to your `~/.tmux.conf`:

``` tmux
set -g @plugin 'RyanMillerC/better-vim-tmux-resizer'
run '~/.tmux/plugins/tpm/tpm'
```

## Configuration

### Custom Key Bindings

If you don't want the plugin to create any mappings, you can use the four
provided functions to define your own custom maps. You will need to define
custom mappings in your `~/.vimrc` as well as update the bindings in tmux to
match.

#### Vim

Add the following to your `~/.vimrc` to define your custom maps:

``` vim
let g:tmux_resizer_no_mappings = 1

nnoremap <silent> {Left-Mapping} :TmuxResizeLeft<CR>
nnoremap <silent> {Down-Mapping} :TmuxResizeDown<CR>
nnoremap <silent> {Up-Mapping} :TmuxResizeUp<CR>
nnoremap <silent> {Right-Mapping} :TmuxResizeRight<CR>
```

**NOTE:** Each instance of `{Left-Mapping}` or `{Down-Mapping}` must be replaced
in the above code with the desired mapping. Ie, the mapping for `<meta-h>` =>
Left would be created with `nnoremap <silent> <meta-h> :TmuxResizeLeft<cr>`.

##### Window Resize Counts 

If the default increments for resizing do not suit your taste, you can
configure this plugin to resize by specific increments both horizontally and
vertically. These are configured with two variables in your `~/.vimrc` file.

For horizontal resizing, set:

``` vim
let g:tmux_resizer_resize_count = 5
```

For vertical resizing, set:

``` vim
let g:tmux_resizer_vertical_resize_count = 10
```

#### Tmux

Alter each of the four lines of the tmux configuration listed above to use your
custom mappings. **Note** each line contains two references to the desired
mapping.

## Troubleshooting

### Vim -> Tmux doesn't work!

This is likely due to conflicting key mappings in your `~/.vimrc`. You can use
the following search pattern to find conflicting mappings
`\vn(nore)?map\s+\<c-[hjkl]\>`. Any matching lines should be deleted or
altered to avoid conflicting with the mappings from the plugin.

Another option is that the pattern matching included in the `.tmux.conf` is
not recognizing that Vim is active. To check that tmux is properly recognizing
Vim, use the provided Vim command `:TmuxNavigatorProcessList`. The output of
that command should be a list like:

```
Ss   -zsh
S+   vim
S+   tmux
```

If you encounter a different output please [open an issue](https://github.com/RyanMillerC/better-vim-tmux-resizer/issues)
with as much info about your OS, Vim version, and tmux version as possible.

### Tmux Can't Tell if Vim Is Active

This functionality requires tmux version 1.8 or higher. You can check your
version to confirm with this shell command:

``` bash
tmux -V # should return 'tmux 1.8'
```

### It Doesn't Work in tmate

[tmate](http://tmate.io/) is a tmux fork that aids in setting up remote pair
programming sessions. It is designed to run alongside tmux without issue, but
occasionally there are hiccups. Specifically, if the versions of tmux and tmate
don't match, you can have issues.

See [this issue](https://github.com/christoomey/vim-tmux-navigator/issues/27) from
vim-tmux-navigator for more detail.

### It Still Doesn't Work!!!

The tmux configuration uses an inlined grep pattern match to help determine if
the current pane is running Vim. If you run into any issues with the resize
not happening as expected, you can open an issue
[here](https://github.com/RyanMillerC/better-vim-tmux-resizer/issues).
