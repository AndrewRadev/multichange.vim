function! multichange#Setup(start, end)
  let b:multichange_start = a:start
  let b:multichange_end   = a:end

  echohl ModeMsg | echo "-- MULTI --" | echohl None
endfunction

function! multichange#Start()
  if !exists('b:multichange_start')
    return
  endif

  let changed_word = s:ChangedWord()

  if changed_word != ''
    let b:multichange_pattern = '\<'.changed_word.'\>'

    let match_pattern = b:multichange_pattern
    if b:multichange_start > 0
      let match_pattern = '\%>'.(b:multichange_start - 1).'l'.match_pattern
    endif
    if b:multichange_end < line('$')
      let match_pattern = match_pattern.'\%<'.(b:multichange_end + 1).'l'
    endif

    call matchadd('Search', match_pattern)
  endif
endfunction

function! multichange#Stop()
  if exists('b:multichange_start') && exists('b:multichange_pattern')
    call s:PerformSubstitution(b:multichange_start, b:multichange_end, b:multichange_pattern)
    unlet b:multichange_start
    unlet b:multichange_end
    unlet b:multichange_pattern
    call clearmatches()
  endif
endfunction

function! s:ChangedWord()
  if col('.') == col('$')
    let at_last_column = 1
  else
    let at_last_column = 0
  endif

  undo
  let word = expand('<cword>')
  redo

  if at_last_column
    call feedkeys("\<right>", 'n')
  endif

  return word
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
