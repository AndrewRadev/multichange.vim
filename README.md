This plugin is originally a fork of https://github.com/adinapoli/vim-markmultiple, but it uses a different interface to accomplish a similar objective. Please check that one out as well.

## Usage

![Demo](http://i.andrewradev.com/b67a88ca3660b2c41f9afe7c1bd88460.gif)

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

### Mapping

Typing `:Multichange` for an action like this is counterproductive. The plugin comes with a mapping to trigger multi mode, which comes in two parts, configurable with `g:multichange_mapping` and `g:multichange_motion_mapping`.

The default values of both are `<c-n>`:

``` vim
let g:multichange_mapping        = '<c-n>'
let g:multichange_motion_mapping = '<c-n>'
```

The first of these is the text object that starts multichange, so you need to combine it with a motion. For instance, `<c-n>ap` would start multichange over the next paragraph, `<c-n>4j` would start it over the next 4 lines and so on.

The second one is the special motion to start a multichange over the entire buffer, so `<c-n><c-n>` would just trigger a global multichange. If you change the motion mapping to, say "n":

``` vim
let g:multichange_motion_mapping = 'n'
```

Then the mapping for a global multichange would be `<c-n>n`.

My personal preference is:

``` vim
let g:multichange_mapping        = 'sm'
let g:multichange_motion_mapping = 'm'
```

This means that starting a global multichange would be `smm`, while starting one only for a ruby method would be `smam`. But this clobbers the `s` key that some people use, so it can't be the default.

If you want to avoid setting mappings, set the variables to empty strings. You would still be able to use the `:Multichange` command:

``` vim
let g:multichange_mapping        = ''
let g:multichange_motion_mapping = ''
```
