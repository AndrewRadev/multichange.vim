function! multichange#ModeState(visual)
  if a:visual
    let start     = line("'<")
    let end       = line("'>")
    let has_range = 1
  else
    let start     = -1
    let end       = -1
    let has_range = 0
  endif

  return {
        \   'start':     start,
        \   'end':       end,
        \   'has_range': has_range,
        \
        \   'saved_cn_mapping':  '',
        \   'saved_cx_mapping':  '',
        \   'saved_esc_mapping': '',
        \ }
endfunction

function! multichange#SubstitutionState(visual)
  if a:visual
    let changed_text = s:GetByMarks('`<', '`>')
    if changed_text != ''
      let pattern = changed_text
    endif
    call feedkeys('gv', 'n')
  else
    let changed_text = expand('<cword>')
    if changed_text != ''
      let pattern = '\<'.changed_text.'\>'
    endif
  endif

  if changed_text == ''
    return {}
  endif

  return {
        \   'pattern':   pattern,
        \   'is_visual': a:visual,
        \ }
endfunction

function! multichange#Setup(visual)
  let b:multichange_mode_state = multichange#ModeState(a:visual)
  call s:ActivateCustomMappings()
  call multichange#EchoModeMessage()
endfunction

function! multichange#Start(visual)
  if !exists('b:multichange_mode_state')
    return
  endif

  let mode_state = b:multichange_mode_state

  let typeahead = s:GetTypeahead()
  let b:multichange_substitution_state = multichange#SubstitutionState(a:visual)
  call feedkeys('c', 'n')
  call feedkeys(typeahead)

  let substitution_state = b:multichange_substitution_state

  if empty(substitution_state)
    unlet b:multichange_substitution_state
  else
    let match_pattern = substitution_state.pattern

    if mode_state.has_range
      let match_pattern = '\%>'.(mode_state.start - 1).'l'.match_pattern
      let match_pattern = match_pattern.'\%<'.(mode_state.end + 1).'l'
    endif

    call matchadd('Search', match_pattern)
  endif
endfunction

function! multichange#Substitute()
  if exists('b:multichange_mode_state') && exists('b:multichange_substitution_state')
    call s:PerformSubstitution(b:multichange_mode_state, b:multichange_substitution_state)
    unlet b:multichange_substitution_state
    call clearmatches()
    call multichange#EchoModeMessage()
  endif
endfunction

function! multichange#Stop()
  if exists('b:multichange_mode_state')
    call s:DeactivateCustomMappings()
    unlet b:multichange_mode_state
  endif

  if exists('b:multichange_substitution_state')
    unlet b:multichange_substitution_state
    call clearmatches()
  endif

  echo
endfunction

function! multichange#EchoModeMessage()
  if exists('b:multichange_mode_state')
    echohl ModeMsg | echo "-- MULTI --" | echohl None
  endif
endfunction

function! s:PerformSubstitution(mode_state, substitution_state)
  try
    let saved_view = winsaveview()

    " build up the range of the substitution
    if a:mode_state.has_range
      let range = a:mode_state.start.','.a:mode_state.end
    else
      let range = '%'
    endif

    " prepare the pattern
    let pattern = escape(a:substitution_state.pattern, '/')

    " figure out the replacement
    if a:substitution_state.is_visual
      let replacement = s:GetByMarks('`<', '`.')
    else
      let replacement = expand('<cword>')
    endif
    if replacement == ''
      return
    endif
    let replacement = escape(replacement, '/&')

    " perform the substitution
    exe range.'s/'.pattern.'/'.replacement.'/ge'
  finally
    call winrestview(saved_view)
  endtry
endfunction

function! s:ActivateCustomMappings()
  let mode_state = b:multichange_mode_state

  let mode_state.saved_esc_mapping = maparg('<esc>', 'n')
  let mode_state.saved_cn_mapping  = maparg('c', 'n')
  let mode_state.saved_cx_mapping  = maparg('c', 'x')

  nnoremap <buffer> c :silent call multichange#Start(0)<cr>
  xnoremap <buffer> c :<c-u>silent call multichange#Start(1)<cr>
  nnoremap <buffer> <esc> :call multichange#Stop()<cr>
endfunction

function! s:DeactivateCustomMappings()
  nunmap <buffer> c
  xunmap <buffer> c
  nunmap <buffer> <esc>

  let mode_state = b:multichange_mode_state

  if mode_state.saved_cn_mapping != ''
    exe 'nnoremap c '.mode_state.saved_cn_mapping
  endif
  if mode_state.saved_cx_mapping != ''
    exe 'xnoremap c '.mode_state.saved_cx_mapping
  endif
  if mode_state.saved_esc_mapping != ''
    exe 'nnoremap <esc> '.mode_state.saved_esc_mapping
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
