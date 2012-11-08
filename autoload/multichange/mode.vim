function! multichange#mode#New(visual)
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
