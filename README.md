*Note: more documentation soon to come*

This plugin is originally a fork of https://github.com/adinapoli/vim-markmultiple, but it uses a different interface to accomplish a similar objective. Please check that one out as well.

## Usage

Press `<c-n>` to activate "Multi" mode. Edit any word in the buffer with a `c` motion (e.g. `cw`, `ciw`, `ct_`, `C`). After exiting insert mode, the word change will propagate throughout the buffer.

Alternatively, mark several lines in visual mode and then enter "Multi" mode by pressing `<c-n>`. The result will be the same, except the change will be limited to words within the marked lines.
