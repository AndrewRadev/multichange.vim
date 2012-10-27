fun! markmultiple#Run()
    if s:GetWordUnderTheCursor() == ""
        let g:mark_multiple_started = 0
    else
        if g:mark_multiple_in_normal_mode
            call markmultiple#Normal()
        endif

        if g:mark_multiple_in_visual_mode
            call markmultiple#Visual()
        endif
    endif
endfunction

fun! markmultiple#Visual()
    if !g:mark_multiple_started
        let g:mark_multiple_starting_curpos = getpos(".")
        let g:mark_multiple_current_chars_on_the_line = col('$')
        let g:mark_multiple_curpos = g:mark_multiple_starting_curpos
    endif

    let g:mark_multiple_started = 1
    let g:mark_multiple_current_chars_on_the_line = col('$')
    let g:mark_multiple_word = s:GetWordUnderTheCursor()
    call markmultiple#SetCursor()
    call s:SelectWord()
    call s:HighlightWord()
    call markmultiple#SwapModes()
endfunction

" This ensures the cursor is properly set.
fun! markmultiple#SetCursor()
    " If we are iterating through words,
    " leave to Vim the matching stuff
    if !g:mark_multiple_searching
        let original_position = getpos('.')

        " Try to match an enclosing bracket/tag. If
        " nothing changes, I'm (almost) sure I'm on a plain word.
        normal! %
        if getpos('.')[2] == original_position[2]
            :execute "normal! F "
            normal! l
            let g:mark_multiple_curpos = original_position
            return
        endif

        " If moved two are the cases:
        " It went forward to the next bracket/tag. In that case, fall back
        " to the original position.
        if getpos('.')[2] > original_position[2]
            call setpos('.', original_position)
            :execute "normal! F "
            normal! l
            let g:mark_multiple_curpos = original_position
            return
        else
            normal! l
            let g:mark_multiple_curpos = getpos('.')
            return
        endif
    endif

    let g:mark_multiple_curpos = getpos('.')
endfun

fun! markmultiple#SwapModes()
    let g:mark_multiple_in_normal_mode = !g:mark_multiple_in_normal_mode
    let g:mark_multiple_in_visual_mode = !g:mark_multiple_in_visual_mode
endfunction

fun! markmultiple#Normal()
    if g:mark_multiple_started
        let g:mark_multiple_searching = 1
        "Go to the next word
        call setpos('.', g:mark_multiple_curpos)

        "Search for the next word, but disable search highlighting
        normal! *
        nohlsearch
    endif

    call markmultiple#SwapModes()
endfunction

fun! markmultiple#Substitute()
    if g:mark_multiple_started
        " Protect against invalid subs.
        let valid_sub = markmultiple#ValidSubstitution(col('$'))
        if !valid_sub
            let new_word = ""
        else
            let new_word = s:GetWordUnderTheCursor()
        endif

        let start = g:mark_multiple_starting_curpos[1]
        let end   = g:mark_multiple_curpos[1]
        silent! execute start .','. end .  's/\v<' . expand(g:mark_multiple_word) .  '>/' . expand(new_word) .'/g'
        let g:mark_multiple_started = 0
        let g:mark_multiple_searching = 0

        " Restore cursor under the last matched
        call setpos('.', g:mark_multiple_curpos)

        " Clear highlighting
        call clearmatches()
    endif
endfunction

" Call this to clear all the highlightings
fun! markmultiple#Clean()
    call clearmatches()
    let g:mark_multiple_started = 0
    let g:mark_multiple_searching = 0
    let g:! = 0
    let g:mark_multiple_in_visual_mode = 1
endfunction

fun! markmultiple#ValidSubstitution(chars_on_the_line)
    " Exploit the length of the prev line to determine if
    " something was changed
    let prev_chars = g:mark_multiple_current_chars_on_the_line
    if a:chars_on_the_line <= (prev_chars - len(g:mark_multiple_word))
        return 0
    endif

    return 1
endfunction

fun! s:GetWordUnderTheCursor()
    return expand("<cword>")
endfunction

fun! s:SelectWord()
    silent! normal! zO
    normal! viw
endfunction

fun! s:HighlightWord()
    let line_to_match = g:mark_multiple_curpos[1]
    let col_start = g:mark_multiple_curpos[2] - 1
    let col_end   = g:mark_multiple_curpos[2] + len(g:mark_multiple_word)
    let pattern = '\%'.line_to_match.'l\%>'.col_start.'c\%<'.col_end.'c'
    call matchadd('Search', pattern)
endfun

" vim: et sw=4
