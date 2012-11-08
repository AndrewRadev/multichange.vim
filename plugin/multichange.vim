if exists("g:loaded_multichange") || &cp
  finish
endif

let g:loaded_multichange = '0.0.1'
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:multichange_mapping')
  let g:multichange_mapping = '<c-n>'
endif

if g:multichange_mapping != ''
  exe 'nnoremap '.g:multichange_mapping.' :     call multichange#Setup(0)<cr>'
  exe 'xnoremap '.g:multichange_mapping.' :<c-u>call multichange#Setup(1)<cr>'
endif

au InsertLeave * call multichange#Substitute()
au InsertLeave * call multichange#EchoModeMessage()
au CursorHold  * call multichange#EchoModeMessage()

let &cpo = s:keepcpo
unlet s:keepcpo

" vim: et sw=2
