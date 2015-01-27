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

command! -nargs=0 -count=0 Multichange call multichange#Setup(<count>)

function! s:MultichangeMotion(_motion_type)
  call setpos("'<", getpos("'["))
  call setpos("'>", getpos("']"))

  call multichange#Setup(1)
endfunction

if g:multichange_mapping != '' && g:multichange_motion_mapping != ''
  exe 'nnoremap <silent>'.g:multichange_mapping.g:multichange_motion_mapping.' :Multichange<cr>'
endif

if g:multichange_mapping != ''
  exe 'nnoremap <silent>'.g:multichange_mapping.' :set opfunc=<SID>MultichangeMotion<cr>g@'
  exe 'xnoremap <silent>'.g:multichange_mapping.' :Multichange<cr>'
endif

au InsertLeave * call multichange#Substitute()
au InsertLeave * call multichange#EchoModeMessage()
au CursorHold  * call multichange#EchoModeMessage()

let &cpo = s:keepcpo
unlet s:keepcpo

" vim: et sw=2
