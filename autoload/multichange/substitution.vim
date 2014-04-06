function! multichange#substitution#New(visual, action)
  let pattern = s:GetPattern(a:visual)

  if pattern == ''
    return {}
  endif

  return {
        \   'pattern':   pattern,
        \   'action':    a:action,
        \   'is_visual': a:visual,
        \
        \   'GetHighlightPattern': function('multichange#substitution#GetHighlightPattern'),
        \   'GetReplacePattern':   function('multichange#substitution#GetReplacePattern'),
        \   'GetReplacement':      function('multichange#substitution#GetReplacement'),
        \ }
endfunction

" TODO (2014-04-06) Better to provide simpler endpoints, #Highlight() and #Replace().
function! multichange#substitution#GetReplacement() dict
  if self.is_visual
    let replacement = s:GetByMarks('`<', '`.')
  else
    let replacement = @.
  endif

  return replacement
endfunction

" Get the pattern used for highlighting the matched areas.
"
function! multichange#substitution#GetHighlightPattern() dict
  return self.pattern
endfunction

" Get the pattern used to find what to replace.
"
function! multichange#substitution#GetReplacePattern() dict
  if self.action == 'c'
    return self.pattern
  elseif self.action == 'i'
    return '\ze'.self.pattern
  elseif self.action == 'a'
    return self.pattern.'\zs'
  endif
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
