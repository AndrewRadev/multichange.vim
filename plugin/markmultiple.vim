if exists("g:loaded_mark_multiple") || &cp
  finish
endif

let g:loaded_mark_multiple = 1
let s:keepcpo = &cpo
set cpo&vim

if !exists("g:mark_multiple_started")
    let g:mark_multiple_started = 0
endif

if !exists("g:mark_multiple_searching")
    let g:mark_multiple_searching = 0
endif

if !exists("g:mark_multiple_in_normal_mode")
    let g:mark_multiple_in_normal_mode = 0
endif

if !exists("g:mark_multiple_in_visual_mode")
    let g:mark_multiple_in_visual_mode = 1
endif

if !exists("g:mark_multiple_current_chars_on_the_line")
    let g:mark_multiple_current_chars_on_the_line = col('$')
endif

" Leave space for user customization.
if !exists("g:mark_multiple_trigger")
    let g:mark_multiple_trigger = "<C-n>"
endif

if g:mark_multiple_trigger != ''
    :execute "nnoremap ". g:mark_multiple_trigger ." :call markmultiple#Run()<CR>"
    :execute "xnoremap ". g:mark_multiple_trigger ." :call markmultiple#Run()<CR>"
endif
au InsertLeave * call markmultiple#Substitute()

let &cpo = s:keepcpo
unlet s:keepcpo

" vim: et sw=4
