#!/bin/bash

layout_file="${HOME}/.config/editor/layout"
layout="$(cat "$layout_file" 2>/dev/null | tr -d '\n\r')"

if [[ "$layout" == "colemak" ]]; then
    command codex --profile local \
        -c tui.vim_mode_default=true \
        -c 'tui.keymap.vim_normal.move_left=["k","left"]' \
        -c 'tui.keymap.vim_normal.move_down=["n","down"]' \
        -c 'tui.keymap.vim_normal.move_up=["e","up"]' \
        -c 'tui.keymap.vim_normal.move_right=["i","right"]' \
        -c 'tui.keymap.vim_normal.move_word_end=["j"]' \
        -c 'tui.keymap.vim_normal.enter_insert=["l"]' \
        "$@"
else
    command codex --profile local \
        -c tui.vim_mode_default=true \
        "$@"
fi
