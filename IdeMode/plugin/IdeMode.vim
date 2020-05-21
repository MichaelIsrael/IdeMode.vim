"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Include guards!
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if exists('g:loaded_IdeMode')
    finish
endif
let g:loaded_IdeMode = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Control variables
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !exists("g:IdeMode_linenumber")
  let g:IdeMode_linenumber = 1
endif
if !exists("g:IdeMode_shell")
  let g:IdeMode_shell = "bash"
endif
if !exists("g:IdeMode_terminal")
  if exists(':term')
    let g:IdeMode_terminal = "term"
  elseif exists(':Terminal')
    let g:IdeMode_terminal = "Terminal"
  endif
endif
let s:IdeMode_active = 0


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Script variables
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"List to store the ide's windows
let s:ide_win_ids = []

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Activation functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:activate()
  "Remember current window.
  let l:curr_win_id = win_getid()

  "Save list of opened windows
  let l:opened_windows = []
  for w in range(1, winnr("$"))
    let l:opened_windows = add(l:opened_windows, win_getid(w))
  endfor

  "Start shell.
  if exists("g:IdeMode_terminal")
    let s:ide_win_ids = add(s:ide_win_ids, s:createTermWin())
  endif

  "Start file explorer.
  let s:ide_win_ids = add(s:ide_win_ids, s:createExplorer())

  "Create buffers window.
  let s:ide_win_ids = add(s:ide_win_ids, s:createBuffersWin())

  if exists(':TagbarToggle')
    let s:ide_win_ids = add(s:ide_win_ids, s:createTagbarWin())
  endif

  "Set number for all originally opened windows
  if g:IdeMode_linenumber
    for wid in l:opened_windows
      exec win_id2win(wid) . "windo set number"
    endfor
  endif

  "Go back to the originally selected window.
  exec win_id2win(l:curr_win_id) . "wincmd w"
endfunction


let s:BufsListBufname = "_IdeBuffersWin"
function! s:createBuffersWin()
  exec "silent rightbelow split" .  s:BufsListBufname
  let win_id = win_getid()
  resize 15
  set wfh
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal nomodifiable
  
  nnoremap <script> <buffer> <silent> <CR> :call <SID>IdeOpenBuffer()<CR>
  nnoremap <script> <buffer> <silent> <2-LeftMouse> :call <SID>IdeOpenBuffer()<CR>
  call s:updateBufferWin()
  return win_id
endfunction


function! <SID>IdeOpenBuffer()
  let l:target_win = winnr("#")
  for w in s:ide_win_ids
    if win_id2win(w) == l:target_win
      "TODO: Find a better idea?
      echom l:target_win
      let l:target_win = 3
      break
    endif
  endfor

  let l:buf_nr = split(getline("."), ")")

  exec l:target_win . "windo buffer" . l:buf_nr[0]
endfunction


function! s:updateBufferWinDelayed()
  call timer_start(100, "_updateBufferWinTimer", {"repeat":0})
endfunction


function! _updateBufferWinTimer(timer)
    call s:updateBufferWin()
endfunction


function! s:updateBufferWin()
  let l:buff_info = getbufinfo(s:BufsListBufname)
  if !empty(l:buff_info)
    let l:buf_wins = l:buff_info[0].windows
    let l:buf_len = l:buff_info[0].linecount

    let l:buffers = map(getbufinfo({'buflisted':1}), 'get(v:val, "bufnr") . ") " . fnamemodify(get(v:val, "name"), ":p:.")')
    let l:buffers_count = len(l:buffers)

    call setbufvar(s:BufsListBufname, "&modifiable", 1)

    call setbufline(s:BufsListBufname, 1, l:buffers)

    
    if l:buffers_count < l:buf_len
      for l in range(l:buffers_count+1, l:buf_len)
        call setbufline(s:BufsListBufname, l, "")
      endfor
    endif
    "call bufdo

    call setbufvar(s:BufsListBufname, "&modifiable", 0)

    if l:buffers_count == 0
      call setbufvar(s:BufsListBufname, "&statusline", "No buffers opened.")
    elseif l:buffers_count == 1
      call setbufvar(s:BufsListBufname, "&statusline", "1 buffer opened.")
    else
      call setbufvar(s:BufsListBufname, "&statusline", l:buffers_count . " buffers opened.")
    endif
  endif
endfunction


function! s:createTermWin()
  exec "botright " .  g:IdeMode_terminal . " " . g:IdeMode_shell
  let win_id = win_getid()
  resize 15
  "Fix window sizes
  set wfh
  setlocal bufhidden=hide
  setlocal nobuflisted
  return win_id
endfunction


function! s:netrw_save_and_adjust()
  " Save global values
  if exists("g:netrw_banner")
    let s:old_netrw_banner       = g:netrw_banner
  endif
  if exists("g:netrw_liststyle")
    let s:old_netrw_liststyle    = g:netrw_liststyle
  endif
  if exists("g:netrw_altv")
    let s:old_netrw_altv         = g:netrw_altv
  endif
  if exists("g:netrw_browse_split")
    let s:old_netrw_browse_split = g:netrw_browse_split
  endif

  let g:netrw_banner = 0
  let g:netrw_liststyle = 3
  let g:netrw_altv = 1
  let l:tab_nr = tabpagenr()
  let l:win_nr = winnr()
  let g:netrw_browse_split = [v:servername, l:tab_nr, 3]
endfunction


function! s:createExplorer()
  call s:netrw_save_and_adjust()
  vertical topleft split
  let win_id = win_getid()
  enew
  Explore
  "Set and fix window sizes
  vertical resize 30
  set wfw
  return win_id
endfunction


function! s:createTagbarWin()
  TagbarToggle
  exec winnr("$") . "wincmd w"
  let win_id = win_getid()
  "Set and fix window sizes
  vertical resize 30
  set wfw
  return win_id
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Deactivation functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:deactivate()
  let l:curr_win_id = win_getid()

  for w in s:ide_win_ids
    exec win_id2win(w) . "quit!"
  endfor
  let s:ide_win_ids = []

  " Restore netrw_settings
  if exists("s:old_netrw_banner")
    let g:netrw_banner       = s:old_netrw_banner
  else
    unlet g:netrw_banner
  endif
  if exists("s:old_netrw_liststyle")
    let g:netrw_liststyle    = s:old_netrw_liststyle
  else
    unlet g:netrw_liststyle
  endif
  if exists("s:old_netrw_altv")
    let g:netrw_altv         = s:old_netrw_altv
  else
    unlet g:netrw_altv
  endif
  if exists("s:old_netrw_browse_split")
    let g:netrw_browse_split = s:old_netrw_browse_split
  else
    unlet g:netrw_browse_split
  endif

  if g:IdeMode_linenumber
  "Reset numbers
    for w in range(1, winnr("$"))
      exec w . "windo set nonumber"
    endfor
  endif

  "Go back to the originally selected window.
  exec win_id2win(l:curr_win_id) . "wincmd w"
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"autocommands.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:createAutoCmd()
  augroup IdeModeAutoCmds
    autocmd!
    autocmd BufAdd,BufFilePost,BufEnter,BufLeave,BufWinEnter,BufWinLeave,BufUnload,BufHidden 
          \ * call s:updateBufferWin()

    autocmd BufDelete,BufWipeout * call s:updateBufferWinDelayed()
  augroup END
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"The main function to toggle the mode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! IdeMode()
  if s:IdeMode_active == 0
    let s:IdeMode_active = 1
    call s:activate()
    call s:createAutoCmd()
  else
    let s:IdeMode_active = 0
    call s:deactivate()
    autocmd! IdeModeAutoCmds
  endif
endfunction

command! -nargs=0 IdeModeToggle call IdeMode()
