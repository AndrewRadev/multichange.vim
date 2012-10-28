if exists("g:loaded_multichange") || &cp
  finish
endif

let g:loaded_multichange = '0.0.1'
let s:keepcpo = &cpo
set cpo&vim

nnoremap <c-n> :     call multichange#Setup(0, line('$'))<cr>
xnoremap <c-n> :<c-u>call multichange#Setup(line("'<"), line("'>"))<cr>

au InsertEnter * call multichange#Start()
au InsertLeave * call multichange#Stop()

let &cpo = s:keepcpo
unlet s:keepcpo

" vim: et sw=2
