" TODO (2012-11-08)
"   - structure for the mode
"   - structure for a single substitution

function! multichange#Setup(visual)
  if a:visual
    let b:multichange_start = line("'<")
    let b:multichange_end   = line("'>")
  else
    let b:multichange_start = 0
    let b:multichange_end   = line('$')
  endif

  call s:ActivateCustomMappings()
  call multichange#EchoModeMessage()
endfunction

function! multichange#Start(visual)
  if !exists('b:multichange_start')
    return
  endif

  let b:multichange_visual = a:visual
  let typeahead = s:GetTypeahead()

  if b:multichange_visual
    let changed_text = s:GetByMarks('`<', '`>')
    if changed_text != ''
      let b:multichange_pattern = changed_text
    endif
    call feedkeys('gvc', 'n')
  else
    let changed_text = expand('<cword>')
    if changed_text != ''
      let b:multichange_pattern = '\<'.changed_text.'\>'
    endif
    call feedkeys('c', 'n')
    call feedkeys(typeahead)
  endif

  if changed_text != ''
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

function! multichange#Substitute()
  if exists('b:multichange_start') && exists('b:multichange_pattern')
    call s:PerformSubstitution(b:multichange_start, b:multichange_end, b:multichange_pattern, b:multichange_visual)
    unlet b:multichange_pattern
    unlet b:multichange_visual
    call clearmatches()
    call multichange#EchoModeMessage()
  endif
endfunction

function! multichange#Stop()
  if exists('b:multichange_start')
    call s:DeactivateCustomMappings()
    unlet b:multichange_start
    unlet b:multichange_end
  endif

  if exists('b:multichange_pattern')
    unlet b:multichange_pattern
    unlet b:multichange_visual
    call clearmatches()
  endif

  echo
endfunction

function! multichange#EchoModeMessage()
  if exists('b:multichange_start')
    echohl ModeMsg | echo "-- MULTI --" | echohl None
  endif
endfunction

function! s:PerformSubstitution(start, end, pattern, visual)
  try
    let saved_view = winsaveview()

    let pattern = escape(a:pattern, '/')

    if a:visual
      let replacement = s:GetByMarks('`<', '`.')
    else
      let replacement = expand('<cword>')
    endif

    if replacement == ''
      return
    endif

    let replacement = escape(replacement, '/&')

    exe a:start.','.a:end.'s/'.pattern.'/'.replacement.'/ge'
  finally
    call winrestview(saved_view)
  endtry
endfunction

function! s:ActivateCustomMappings()
  if maparg('<esc>', 'n') != ''
    let b:multichange_saved_esc_mapping = maparg('<esc>', 'n')
  endif
  if maparg('c', 'n') != ''
    let b:multichange_saved_cn_mapping = maparg('c', 'n')
  endif
  if maparg('c', 'x') != ''
    let b:multichange_saved_cx_mapping = maparg('c', 'x')
  endif

  nnoremap <buffer> c :silent call multichange#Start(0)<cr>
  xnoremap <buffer> c :<c-u>silent call multichange#Start(1)<cr>
  nnoremap <buffer> <esc> :call multichange#Stop()<cr>
endfunction

function! s:DeactivateCustomMappings()
  nunmap <buffer> c
  xunmap <buffer> c
  nunmap <buffer> <esc>

  if exists('b:multichange_saved_cn_mapping')
    exe 'nnoremap c '.b:multichange_saved_cn_mapping
    unlet b:multichange_saved_cn_mapping
  endif
  if exists('b:multichange_saved_cx_mapping')
    exe 'xnoremap c '.b:multichange_saved_cx_mapping
    unlet b:multichange_saved_cx_mapping
  endif
  if exists('b:multichange_saved_esc_mapping')
    exe 'nnoremap <esc> '.b:multichange_saved_esc_mapping
    unlet b:multichange_saved_esc_mapping
  endif
endfunction

function! s:GetByMarks(start, end)
  try
    let saved_view = winsaveview()

    let original_reg      = getreg('z')
    let original_reg_type = getregtype('z')

    exec 'normal! '.a:start.'v'.a:end.'"zy'
    let text = @z
    call setreg('z', original_reg, original_reg_type)

    return text
  finally
    call winrestview(saved_view)
  endtry
endfunction

function! s:GetTypeahead()
  let typeahead = ''

  let char = getchar(0)
  while char != 0
    let typeahead .= nr2char(char)
    let char = getchar(0)
  endwhile

  return typeahead
endfunction
