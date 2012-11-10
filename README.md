This plugin is originally a fork of https://github.com/adinapoli/vim-markmultiple, but it uses a different interface to accomplish a similar objective. Please check that one out as well.

## Usage

The plugin exposes a command, `:Multichange`, that enters a special "multi" mode. In this mode, any change of a word with a "c" mapping is propagated throughout the entire file. Example:

``` python
def add(one, two):
    return one + two
```

If we wanted to rename the "one" parameter to "first" and the "two" parameter to "second", we could do it in a number of ways using either the `.` mapping or substitutions. With multichange, we execute the `:Multichange` command, and then perform the `cw` operation on "one" and "two" within the argument list. Changing them to "first" and "second" will be performed for the entire file.

Note that this works similarly to the `*` mapping -- it replaces words only, so it won't replace the "one" in "one_more_thing".

To exit "multi" mode, press `<esc>`. To limit the "multi" mode to only an area of the file (for example, to rename variables within a single function definition), select the desired area and then execute `:Multichange`.

You can also make a change in visual mode. For example, you want to change a function name in Vimscript:

``` vim
function! s:BadName()
endfunction

call s:BadName()
```

Since `:` is not in `iskeyword` (I think), you might have problems changing the function name using word motions. In this case, start "multi" mode as described above, then mark `s:BadName` in characterwise visual mode (with `v`). After pressing `c`, change the name to whatever you like. This will propagate the same way as the word change from before. The difference is that whatever was selected will be changed, regardless of word boundaries. So, if you only select "Name" and change it, any encounter of "Name" will be replaced.

The plugin also exposes a simple mapping for the `:Multichange` command, which is `<c-n>` by default. Modify `g:multichange_mapping` to change it. Set `g:multichange_mapping` to an empty string to avoid setting any mapping at all.

``` vim
" change mapping to "_n":
let g:multichange_mapping = '_n'

" disable mapping entirely
let g:multichange_mapping = ''
```

## TODO

- Make it work with "i" and "a" as well as with "c".
