# ~/.bashrc: executed by bash(1) for non-login shells.
#
# layout:
#   part 1: environment. everything here is exported, so fish inherits it
#   guard:  interactive sessions get handed to fish (set NOFISH=1 to stay in bash)
#   part 2: bash-only interactive setup, only reached when staying in bash
#
# shared with fish:
#   ~/.local/bin              commands, from ~/.dotfiles/scripts (link_scripts.sh)
#   ~/.config/shell/aliases   aliases
#   ~/.config/shell/vi-keys   vi key layout table
#   ~/.config/starship.toml   prompt

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# //==========================================//
# //========= part 1: environment ===========//
# //==========================================//
#
# //============ configure device ============//
# //==========================================//
# default configs
envdir=$HOME/.envs
uv_python_dir=$HOME/.local/share/uv/python # uv's default
uv_cache_dir=$HOME/.cache/uv # uv's default

# load local variables
if [ -f ~/.bash_vars ]; then
    # ex. could override envdir, uv_python_dir, uv_cache_dir.
    # set -a exports everything it defines, so fish gets these too
    set -a
    source ~/.bash_vars
    set +a
fi
export envdir uv_python_dir uv_cache_dir

# where uv installs pythons and keeps its download cache. keep the cache on the same
# drive as envdir so uv can link packages instead of copying them
export UV_PYTHON_INSTALL_DIR="$uv_python_dir"
export UV_CACHE_DIR="$uv_cache_dir"
# only use uv's own pythons, never the system one in /usr/bin
export UV_PYTHON_PREFERENCE=only-managed

if grep -q "^ID=arch" /etc/os-release 2>/dev/null; then
    is_arch=true
else
    is_arch=false
fi

# msys2 on windows
case "$OSTYPE" in
    msys*|cygwin*) is_msys=true ;;
    *) is_msys=false ;;
esac
export is_arch is_msys
# //==========================================//
# //==========================================//
#
# //================== path ==================//
# //==========================================//
# stuff that needs to be added to path
remove_path_duplicates() {
    export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
}

# bin
export PATH=/usr/bin:$PATH

# local stuff (also where the scripts from ~/.dotfiles/scripts get linked)
export PATH=$HOME/.local/bin:$PATH

# nvm. only node's PATH carries over to fish, the nvm command itself is bash-only
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # this loads nvm

# cuda
if [ -d /opt/cuda ]; then
    export PATH=/opt/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
fi

# go
export GOPATH="$HOME/.local/share/go"
export PATH="$PATH:$GOPATH/bin"

# rust
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env" # sourcing this adds .cargo/bin to path and other things
fi
# //==========================================//
# //==========================================//
#
# //=============== appearance ===============//
# //==========================================//
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# colors for ls (LS_COLORS is exported, so fish uses it too)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# starship draws the venv name itself, so stop activate scripts adding a second one
command -v starship >/dev/null 2>&1 && export VIRTUAL_ENV_DISABLE_PROMPT=1
# //==========================================//
# //==========================================//
#
# //================= editor =================//
# //==========================================//
export EDITOR=vim
export VISUAL=vim
export NEOVIM_PATH="$HOME/.config/nvim"

# vi key layout persists in LAYOUT_FILE (colemak / qwerty, see setc / setq).
# the key table itself is shared with fish
export EDITOR_SETTINGS_DIR="${HOME}/.config/editor"
export LAYOUT_FILE="${EDITOR_SETTINGS_DIR}/layout"
export VI_KEYS_FILE="$HOME/.config/shell/vi-keys"
mkdir -p "$EDITOR_SETTINGS_DIR"
# //==========================================//
# //==========================================//
#
# //================= local ==================//
# //==========================================//
# machine-specific stuff. only exported variables carry over to fish
if [[ -f "$HOME/.bash_local" ]]; then
    source "$HOME/.bash_local"
fi
# //==========================================//
# //==========================================//
#
# //================ cleanup =================//
# //==========================================//
unset_venv() {
    # a terminal opened from inside a venv (ex. a neovim :terminal) inherits that venv.
    # clear it so every new shell starts clean
    unset VIRTUAL_ENV
    if [ -n "$PATH" ]; then
        # remove all the env paths
        export PATH=$(echo "$PATH" | tr ':' '\n' | grep -vF "$envdir/" | tr '\n' ':' | sed 's/:$//')
    fi
}

unset_venv
remove_path_duplicates
# //==========================================//
# //==========================================//
#
#
# //==========================================//
# //============ guard: hand to fish =========//
# //==========================================//
# interactive sessions run fish instead. the login shell stays bash, so scripts and
# anything that runs bash directly are unaffected.
# stays in bash if: NOFISH is set (ex. NOFISH=1 bash), fish isn't installed, or bash was
# started from fish (you typed `bash` in fish on purpose)
_parent=""
read -r _parent 2>/dev/null < "/proc/$PPID/comm" \
    || read -r _parent 2>/dev/null < "/proc/$PPID/exename" # msys2 has exename, not comm
_parent=${_parent##*/}
if [[ -z ${NOFISH-} && $_parent != fish && $_parent != fish.exe ]] \
    && command -v fish >/dev/null 2>&1; then
unset _parent
exec fish
fi
unset _parent
# //==========================================//
# //==========================================//
#
#
# //==========================================//
# //====== part 2: bash-only interactive =====//
# //==========================================//
#
# //================ history =================//
# //==========================================//
# don't put duplicate lines or lines starting with space in the history.
# see bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
# //==========================================//
# //==========================================//
#
# //================== gen ===================//
# //==========================================//
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# if set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# aliases shared with fish
[ -f ~/.config/shell/aliases ] && source ~/.config/shell/aliases

alias src='source ~/.bashrc'

# add an "alert" alias for long running commands.  use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# //==========================================//
# //==========================================//
#
# //============== autocomplete ==============//
# //==========================================//
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # nvm bash_completion
# //==========================================//
# //==========================================//
#
# //================= prompt =================//
# //==========================================//
_notify_nvim_hook() {
    # runs before every prompt. calls notify_nvim only when the directory changed and
    # we're inside neovim, so normal prompts just cost one string comparison
    local status=$?
    if [[ $PWD != "${_last_pwd-}" ]]; then
        _last_pwd=$PWD
        [[ -n ${NVIM-} ]] && notify_nvim
    fi
    return $status
}
PROMPT_COMMAND="_notify_nvim_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    # fallback when starship isn't installed: just "$ "
    PS1='\[\033[0;36m\]\$ \[\033[0m\]'
fi

# zoxide, as e
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd e)"
# //==========================================//
# //==========================================//
#
# //================== vim ===================//
# //==========================================//
set_vim() {
    # vi mode, the key layout from $LAYOUT_FILE (rows from the shared $VI_KEYS_FILE),
    # and clipboard paste / yank
    set -o vi

    local paste_cmd copy_cmd

    if command -v wl-paste >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
        paste_cmd='wl-paste'
        copy_cmd='wl-copy'
    elif command -v xclip >/dev/null 2>&1; then
        paste_cmd='xclip -selection clipboard -o'
        copy_cmd='xclip -selection clipboard'
    elif [ -e /dev/clipboard ]; then # msys2
        paste_cmd='cat /dev/clipboard'
        copy_cmd='cat > /dev/clipboard'
    else
        paste_cmd=''
        copy_cmd=''
    fi

    if [[ -n "$paste_cmd" && -n "$copy_cmd" ]]; then
        bind -m vi-command -x "\"p\": CLIP=\$($paste_cmd | sed -z 's/\r//g; s/\n/;\n/g; s/[;\n]*$//') && READLINE_LINE=\"\${READLINE_LINE:0:READLINE_POINT+1}\${CLIP}\${READLINE_LINE:READLINE_POINT+1}\" && READLINE_POINT=\$((READLINE_POINT + \${#CLIP}))"
            bind -m vi-command -x "\"yy\": printf '%s' \"\$READLINE_LINE\" | $copy_cmd"
    fi

    [ -f "$LAYOUT_FILE" ] && [ -f "$VI_KEYS_FILE" ] || return 0

    local key_layout layout key readline_fn _
    key_layout=$(tr -d '\n\r' < "$LAYOUT_FILE")

    # bind the rows for this layout. '-' means no readline equivalent
    while read -r layout key readline_fn _; do
        [[ -z $layout || $layout == \#* ]] && continue
            [[ $layout == "$key_layout" && $readline_fn != - ]] || continue
        bind -m vi-command "\"$key\": $readline_fn"
    done < "$VI_KEYS_FILE"
}

setc() {
    # set the current vim layout to colemak
    echo "colemak" > "$LAYOUT_FILE"
    set_vim
    echo "changed layout to colemak-dh"
}

setq() {
    # set the current vim layout to qwerty
    echo "qwerty" > "$LAYOUT_FILE"
    set_vim
    echo "changed layout to qwerty"
}
# //==========================================//
# //==========================================//
#
# //================ python ==================//
# //==========================================//
actvenv() {
    # activate venv <name> from $envdir. has to be a function since it changes this
    # shell. the shared lookup logic is in the venvpath script
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "in a virtual environment already at: $VIRTUAL_ENV. deactivate first."
    fi
    local bin
    bin=$(venvpath "$1") || return 1
    source "$bin/activate"
}
# //==========================================//
# //==========================================//
#
# //================= script =================//
# //==========================================//
# anything that needs to be run at the end
welcome
set_vim
