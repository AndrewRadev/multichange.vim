if exists("g:loaded_mark_multiple") || &cp
  finish
endif

let g:loaded_mark_multiple = 1
let s:keepcpo = &cpo
set cpo&vim

nnoremap <c-n> :     call <SID>StartMultimark(0,          line('$'))<cr>
xnoremap <c-n> :<c-u>call <SID>StartMultimark(line("'<"), line("'>"))<cr>

function! s:StartMultimark(start, end)
  let b:mark_multiple_start = a:start
  let b:mark_multiple_end   = a:end

  echohl ModeMsg | echo "-- MULTI --" | echohl None
endfunction

au InsertEnter * call s:MultimarkEnter()
au InsertLeave * call s:MultimarkLeave()

function! s:MultimarkEnter()
  if !exists('b:mark_multiple_start')
    return
  endif

  let changed_word = @"

  if changed_word != ''
    let b:mark_multiple_pattern = '\<'.changed_word.'\>'

    let match_pattern = b:mark_multiple_pattern
    if b:mark_multiple_start > 0
      let match_pattern = '\%>'.(b:mark_multiple_start - 1).'l'.match_pattern
    endif
    if b:mark_multiple_end < line('$')
      let match_pattern = match_pattern.'\%<'.(b:mark_multiple_end + 1).'l'
    endif

    call matchadd('Search', match_pattern)
  endif
endfunction

function! s:MultimarkLeave()
  if exists('b:mark_multiple_start') && exists('b:mark_multiple_pattern')
    call s:PerformSubstitution(b:mark_multiple_start, b:mark_multiple_end, b:mark_multiple_pattern)
    unlet b:mark_multiple_start
    unlet b:mark_multiple_end
    unlet b:mark_multiple_pattern
    call clearmatches()
  endif
endfunction

function! s:PerformSubstitution(start, end, pattern)
  try
    let saved_view = winsaveview()

    let pattern     = escape(a:pattern, '/')
    let replacement = escape(expand('<cword>'), '/&')

    if replacement == ''
      return
    endif

    exe a:start.','.a:end.'s/'.pattern.'/'.replacement.'/ge'
  finally
    call winrestview(saved_view)
  endtry
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

" vim: et sw=2
