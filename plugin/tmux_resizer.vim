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
    let l:command = 'vertical resize ' . l:modifier . g:window_resize_count . '<CR>'
  else
    let l:command = 'resize ' . l:modifier . g:window_resize_count . '<CR>'
  endif

  execute l:command
endfunction

function! s:VimResize(direction)
  try
    if a:direction == 'h'
        call s:IntelligentVimResize('left')
    elseif a:direction == 'j'
        call s:IntelligentVimResize('down')
    elseif a:direction == 'k'
        call s:IntelligentVimResize('up')
    elseif a:direction == 'l'
        call s:IntelligentVimResize('right')
    endif
  catch
    " TODO: Figure out if better error should be displayed
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

if !get(g:, 'tmux_resizer_no_mappings', 0)
  " TODO: Switch back to these mappings
  " nnoremap <silent> <M-h> :TmuxResizeLeft<cr>
  " nnoremap <silent> <M-j> :TmuxResizeDown<cr>
  " nnoremap <silent> <M-k> :TmuxResizeUp<cr>
  " nnoremap <silent> <M-l> :TmuxResizeRight<cr>

  nnoremap <silent> <M-Left> :TmuxResizeLeft<cr>
  nnoremap <silent> <M-Down> :TmuxResizeDown<cr>
  nnoremap <silent> <M-Up> :TmuxResizeUp<cr>
  nnoremap <silent> <M-Right> :TmuxResizeRight<cr>
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

" TODO: Figure out if this is even relevant - part 1
if !exists("g:tmux_navigator_disable_when_zoomed")
  let g:tmux_navigator_disable_when_zoomed = 0
endif

function! s:TmuxOrTmateExecutable()
  return (match($TMUX, 'tmate') != -1 ? 'tmate' : 'tmux')
endfunction

" TODO: Figure out if this is even relevant - part 2
function! s:TmuxVimPaneIsZoomed()
  return s:TmuxCommand("display-message -p '#{window_zoomed_flag}'") == 1
endfunction

function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
  let cmd = s:TmuxOrTmateExecutable() . ' -S ' . s:TmuxSocket() . ' ' . a:args
  return system(cmd)
endfunction

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxNavigatorProcessList call s:TmuxNavigatorProcessList()

let s:tmux_is_last_pane = 0
augroup tmux_navigator
  au!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
  if g:tmux_navigator_disable_when_zoomed && s:TmuxVimPaneIsZoomed()
    return 0
  endif
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

  " TODO: Figure out what this line under here means...
  " b) we tried switching windows in vim but it didn't have effect.
  if s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
    " TODO: Maybe delete this line
    " let args = 'resize-pane -t ' . shellescape($TMUX_PANE) . ' -' . tr(a:direction, 'hjkl', 'LDUR')
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
