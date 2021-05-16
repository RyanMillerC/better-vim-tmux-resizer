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
  " Prevent resizing Vim upward when there is only a single window
  if (a:direction == 'j' && winnr('$') <= 1)
    return
  endif

  " Prevent resizing Vim upwards when all windows are vsplit
  if (a:direction == 'k' || a:direction == 'j')
    let l:all_windows_are_vsplit = 1
    for l:window in range(1, winnr('$'))
      if (win_screenpos(l:window)[0] != 1)
        let l:all_windows_are_vsplit = 0
      endif
    endfor
    if (l:all_windows_are_vsplit)
      return
    endif
  endif

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
