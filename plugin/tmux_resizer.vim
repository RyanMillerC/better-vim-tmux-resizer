" Maps <M-h/j/k/l> to resize vim splits in the given direction. If there
" are no more windows in that direction, forwards the operation to tmux.

if exists("g:loaded_tmux_resizer") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_resizer = 1

function! s:IntelligentVimResize(direction) abort
  let g:window_resize_count = get(g:, 'window_resize_count', 5)
  let l:current_window_is_last_window = (winnr() == winnr('$'))

  if (a:direction ==# 'left' || a:direction ==# 'up')
    let [l:modifier_1, l:modifier_2] = ['+', '-']
  else
    let [l:modifier_1, l:modifier_2] = ['-', '+']
  endif
  let l:modifier = l:current_window_is_last_window ? l:modifier_1 : l:modifier_2

  if (a:direction ==# 'left' || a:direction ==# 'right')
    let l:command = 'vertical resize'
  else
    let l:command = 'resize'
  endif
  execute l:command . ' ' . l:modifier . g:window_resize_count . '<CR>'
endfunction

function! s:VimResize(direction)
  if a:direction == 'h'
      call s:IntelligentVimResize('left')
  elseif a:direction == 'j'
      call s:IntelligentVimResize('down')
  elseif a:direction == 'k'
      call s:IntelligentVimResize('up')
  elseif a:direction == 'l'
      call s:IntelligentVimResize('right')
  endif
endfunction

if !get(g:, 'tmux_resizer_no_mappings', 0)
  nnoremap <silent> <M-h> :TmuxResizeLeft<CR>
  nnoremap <silent> <M-j> :TmuxResizeDown<CR>
  nnoremap <silent> <M-k> :TmuxResizeUp<CR>
  nnoremap <silent> <M-l> :TmuxResizeRight<CR>
endif

if empty($TMUX)
  command! TmuxResizeLeft call s:VimResize('h')
  command! TmuxResizeDown call s:VimResize('j')
  command! TmuxResizeUp call s:VimResize('k')
  command! TmuxResizeRight call s:VimResize('l')
  finish
endif

command! TmuxResizeLeft call s:TmuxAwareResize('h')
command! TmuxResizeDown call s:TmuxAwareResize('j')
command! TmuxResizeUp call s:TmuxAwareResize('k')
command! TmuxResizeRight call s:TmuxAwareResize('l')

function! s:TmuxOrTmateExecutable()
  return (match($TMUX, 'tmate') != -1 ? 'tmate' : 'tmux')
endfunction

function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
  let cmd = s:TmuxOrTmateExecutable() . ' -S ' . s:TmuxSocket() . ' ' . a:args
  return system(cmd)
endfunction

function! s:TmuxResizerProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxResizerProcessList call s:TmuxResizerProcessList()

let s:tmux_is_last_pane = 0
augroup tmux_resizer
  au!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:ShouldForwardResizeBackToTmux(tmux_last_pane, at_tab_page_edge)
  return a:tmux_last_pane || a:at_tab_page_edge
endfunction

function! s:TmuxAwareResize(direction)
  let nr = winnr()
  let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
  if !tmux_last_pane
    call s:VimResize(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())
  " Forward the resize panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried resizing windows in vim but it didn't have effect.
  if s:ShouldForwardResizeBackToTmux(tmux_last_pane, at_tab_page_edge)
    " TODO: Allow user to specify resize amount
    let args = 'resize-pane -' . tr(a:direction, 'hjkl', 'LDUR') . ' 5'
    silent call s:TmuxCommand(args)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction
