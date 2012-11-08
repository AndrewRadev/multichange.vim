function! multichange#substitution#New(visual)
  let pattern = s:GetPattern(a:visual)

  if pattern == ''
    return {}
  endif

  return {
        \   'pattern':   pattern,
        \   'is_visual': a:visual,
        \
        \   'GetReplacement': function('multichange#substitution#GetReplacement'),
        \ }
endfunction

function! multichange#substitution#GetReplacement() dict
  if self.is_visual
    let replacement = s:GetByMarks('`<', '`.')
  else
    let replacement = expand('<cword>')
  endif

  return replacement
endfunction

function! s:GetPattern(visual)
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

  return pattern
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
