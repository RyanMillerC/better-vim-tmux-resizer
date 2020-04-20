" Maps <M-h/j/k/l> to resize vim splits in the given direction.
" If the movement operation has no effect in Vim, it forwards the operation to
" Tmux.

if exists("g:loaded_tmux_resizer") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_resizer = 1

if !exists("g:tmux_resizer_resize_count")
  let g:tmux_resizer_resize_count = 5
endif

if !exists("g:tmux_resizer_vertical_resize_count")
  let g:tmux_resizer_vertical_resize_count = 10
endif

if !exists("g:tmux_resizer_no_mappings")
  nnoremap <silent> <M-h> :TmuxResizeLeft<CR>
  nnoremap <silent> <M-j> :TmuxResizeDown<CR>
  nnoremap <silent> <M-k> :TmuxResizeUp<CR>
  nnoremap <silent> <M-l> :TmuxResizeRight<CR>
endif

function! s:VimResize(direction)
  " Resize Vim window toward given direction, like tmux
  let l:current_window_is_last_window = (winnr() == winnr('$'))
  if (a:direction == 'h' || a:direction == 'k')
    let l:modifier = l:current_window_is_last_window ? '+' : '-'
  else
    let l:modifier = l:current_window_is_last_window ? '-' : '+'
  endif

  if (a:direction == 'h' || a:direction == 'l')
    let l:command = 'vertical resize'
    let l:window_resize_count = g:tmux_resizer_vertical_resize_count
  else
    let l:command = 'resize'
    let l:window_resize_count = g:tmux_resizer_resize_count
  endif

  execute l:command . ' ' . l:modifier . l:window_resize_count . '<CR>'
endfunction

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

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:TmuxAwareResize(direction)
  let l:previous_window_width = winwidth(0)
  let l:previous_window_height = winheight(0)

  " Attempt to resize Vim window
  call s:VimResize(a:direction)

  " Call tmux if Vim window dimentions did not change
  if (l:previous_window_height == winheight(0) && l:previous_window_width == winwidth(0))
    if (a:direction == 'h' || a:direction == 'l')
      let l:resize_count = g:tmux_resizer_vertical_resize_count
    else
      let l:resize_count = g:tmux_resizer_resize_count
    endif
    let args = 'resize-pane -' . tr(a:direction, 'hjkl', 'LDUR') . ' ' . l:resize_count

    silent call s:TmuxCommand(args)

    if s:NeedsVitalityRedraw()
      redraw!
    endif
  endif
endfunction

" For debugging
function! s:TmuxResizerProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxResizerProcessList call s:TmuxResizerProcessList()
