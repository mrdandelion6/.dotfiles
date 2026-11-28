# fish config.
#
# bash runs first (it's the login shell) and hands interactive sessions to fish at the
# end of part 1 of ~/.bashrc, so every exported variable (PATH, envdir, uv, LS_COLORS,
# LAYOUT_FILE, ...) is already set when this runs. only things that change this shell
# itself live here; everything else is a command in ~/.local/bin shared with bash.

status is-interactive; or exit

# welcome prints instead of fish's default greeting
set -g fish_greeting

# //================ aliases =================//
# //==========================================//
# aliases shared with bash
test -f ~/.config/shell/aliases; and source ~/.config/shell/aliases

alias src='source ~/.config/fish/config.fish'

function alert --description 'notify when the previous command finishes (use: cmd; alert)'
    set -l last_status $status
    set -l icon terminal
    test $last_status -eq 0; or set icon error
    notify-send --urgency=low -i $icon (string replace -r '\s*[;&|]\s*alert$' '' -- $history[1])
end
# //==========================================//
# //==========================================//
#
# //================= prompt =================//
# //==========================================//
function _notify_nvim_hook --on-variable PWD --description 'tell neovim our directory when it changes'
    set -q NVIM; and notify_nvim
end
# once at startup, like the first prompt does in bash
set -q NVIM; and notify_nvim

# no [N]/[I] vi mode indicator in front of the prompt, to match bash
function fish_mode_prompt
end

type -q starship; and starship init fish | source

# zoxide, as e
type -q zoxide; and zoxide init fish --cmd e | source
# //==========================================//
# //==========================================//
#
# //================== vim ===================//
# //==========================================//
function set_vim --description 'apply the vi key layout and clipboard bindings'
    # vi normal-mode remaps from the shared $VI_KEYS_FILE, for the layout in $LAYOUT_FILE.
    # these are user bindings on top of fish's vi presets, so erasing one brings the
    # preset back
    if test -f "$VI_KEYS_FILE"
        set -l rows
        for line in (string match -rv '^\s*(#|$)' < $VI_KEYS_FILE)
            set -a rows (string replace -ar '\s+' ' ' -- (string trim -- $line))
        end

        # clear the remaps from before, so switching layouts doesn't leave stale keys
        for row in $rows
            set -l f (string split ' ' -- $row)
            bind -M default -e $f[2] 2>/dev/null
        end

        set -l layout
        test -f "$LAYOUT_FILE"; and set layout (string trim -- (cat $LAYOUT_FILE))

        for row in $rows
            set -l f (string split ' ' -- $row)
            test "$f[1]" = "$layout"; or continue
            switch $f[4]
                case -
                    continue # no fish equivalent
                case 'mode:*'
                    bind -M default -m (string replace 'mode:' '' -- $f[4]) $f[2] repaint-mode
                case '*'
                    bind -M default $f[2] (string split ',' -- $f[4])
            end
        end
    end

    # clipboard paste / yank. fish finds wl-copy, xclip, etc. on its own
    bind -M default p fish_clipboard_paste
    bind -M default yy fish_clipboard_copy
end

function setc --description 'set the vim layout to colemak'
    echo colemak > $LAYOUT_FILE
    set_vim
    echo "changed layout to colemak-dh"
end

function setq --description 'set the vim layout to qwerty'
    echo qwerty > $LAYOUT_FILE
    set_vim
    echo "changed layout to qwerty"
end

# fish calls fish_user_key_bindings after loading the vi presets, so our binds go on top.
# it has to be defined before fish_key_bindings is set
function fish_user_key_bindings
    set_vim
end
set -g fish_key_bindings fish_vi_key_bindings
# //==========================================//
# //==========================================//
#
# //================ python ==================//
# //==========================================//
function actvenv --description 'activate venv <name> from $envdir'
    # has to be a function since it changes this shell. the shared lookup logic is in
    # the venvpath script
    if set -q VIRTUAL_ENV
        echo "in a virtual environment already at: $VIRTUAL_ENV. deactivate first."
    end
    set -l bin (venvpath $argv[1]); or return 1
    source $bin/activate.fish
end
# //==========================================//
# //==========================================//
#
# //================= script =================//
# //==========================================//
# anything that needs to be run at the end
welcome
