if exists("g:loaded_multichange") || &cp
  finish
endif

let g:loaded_multichange = '0.2.0'
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:multichange_mapping')
  let g:multichange_mapping = '<c-n>'
endif

if !exists('g:multichange_motion_mapping')
  let g:multichange_motion_mapping = '<c-n>'
endif

if !exists('g:multichange_save_position')
  let g:multichange_save_position = 1
endif

if !exists('g:multichange_show_match_count')
  let g:multichange_show_match_count = 1
endif

command! -nargs=0 -count=0 Multichange call multichange#Setup(<count>)

let s:memo_position = []

function! s:SavePosition()
  let s:memo_position = getpos('.')
endfunction

function! s:MultichangeMotion(_motion_type)
  call setpos("'<", getpos("'["))
  call setpos("'>", getpos("']"))

  call multichange#Setup(1)

  if g:multichange_save_position && len(s:memo_position) > 0
    call setpos('.', s:memo_position)
    let s:memo_position = []
    redraw
  endif
endfunction

if g:multichange_mapping != '' && g:multichange_motion_mapping != ''
  exe 'nnoremap <silent> '.g:multichange_mapping.g:multichange_motion_mapping.' :Multichange<cr>'
endif

if g:multichange_mapping != ''
  exe 'nnoremap <silent> '.g:multichange_mapping.' :call <SID>SavePosition() \| set opfunc=<SID>MultichangeMotion<cr>g@'
  exe 'xnoremap <silent> '.g:multichange_mapping.' :Multichange<cr>'
endif

au InsertLeave * call multichange#Substitute()
au InsertLeave * call multichange#EchoModeMessage()
au CursorHold  * call multichange#EchoModeMessage()

let &cpo = s:keepcpo
unlet s:keepcpo

" vim: et sw=2
