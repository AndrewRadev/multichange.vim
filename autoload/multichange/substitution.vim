function! multichange#substitution#New(visual, start_pos)
  let pattern = s:GetPattern(a:visual)

  if pattern == ''
    return {}
  endif

  let pattern = '\C'.pattern

  return {
        \   'pattern':   pattern,
        \   'is_visual': a:visual,
        \   'start_pos': a:start_pos,
        \
        \   'GetReplacement': function('multichange#substitution#GetReplacement'),
        \ }
endfunction

function! multichange#substitution#GetReplacement() dict
  if self.is_visual
    let replacement = s:GetByMarks(getpos("'<"), getpos("'."))
  else
    let replacement = s:GetByMarks(self.start_pos, getpos("'."))
  endif

  return replacement
endfunction

function! s:GetPattern(visual)
  if a:visual
    let changed_text = s:GetByMarks(getpos("'<"), getpos("'>"))
    if changed_text != ''
      let pattern = '\V'.escape(changed_text, '\').'\m'
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

function! s:GetByMarks(start_pos, end_pos)
  try
    let saved_view = winsaveview()

    let original_reg      = getreg('z')
    let original_reg_type = getregtype('z')

    call setpos('.', a:start_pos)
    call setpos("'z", a:end_pos)
    normal! v`z"zy

    let text = @z
    call setreg('z', original_reg, original_reg_type)

    return text
  finally
    call winrestview(saved_view)
  endtry
endfunction
