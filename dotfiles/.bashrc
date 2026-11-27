# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

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
# //=============== appearance ===============//
# //==========================================//
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # we have color support; assume it's compliant with ecma-48 (ISO/IEC-6429). (lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[00;31m\]\u@\h\[\033[00m\]:\[\033[01;30m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# if this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# //==========================================//
# //==========================================//
#
# //================= alerts =================//
# //==========================================//
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
# //==========================================//
# //==========================================//
#
# //============ configure device ============//
# //==========================================//
# configure device
# default configs
envdir=$HOME/.envs
uv_python_dir=$HOME/.local/share/uv/python # uv's default
uv_cache_dir=$HOME/.cache/uv # uv's default

# load local variables
if [ -f ~/.bash_vars ]; then
    # ex. could override envdir, uv_python_dir, uv_cache_dir
    source ~/.bash_vars
fi

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

# local stuff
export PATH=$HOME/.local/bin:$PATH

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # this loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # this loads nvm bash_completion

# cuda
export PATH=/opt/cuda/bin:$PATH
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH

# go
export GOPATH="$HOME/.local/share/go"
export PATH="$PATH:$GOPATH/bin"

# colors
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# rust
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env" # sourcing this adds .cargo/bin to path and other things
fi
# //==========================================//
# //==========================================//
#
# //================== gen ===================//
# //==========================================//
# in this section you will find general utility tools

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# if set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# alias that shows my custom functions
alias als='echo "=== CUSTOM ALIASES ===
als        : list all custom functions, aliases, and variables
src        : source ~/.bashrc
vi         : alias for vim
python     : alias for python3
alert      : notify when long command finishes

=== DISPLAY & NAVIGATION ===
hp         : hide shell path (show only $)
sp         : show full shell path
welcome    : print welcome message with ascii art/fastfetch

=== GIT FUNCTIONS ===
pushall    : push to all git remotes
pullall    : pull from all git remotes

=== PYTHON ENVIRONMENT ===
invenv     : check if in virtual environment
actvenv    : activate virtual environment (usage: actvenv <name>)
mkvenv     : create new virtual environment with uv (usage: mkvenv <name> [python_version])
upvenv     : rebuild a venv on another python, keeping its packages (usage: upvenv <name> <python_version>)
lsvenv     : list virtual environments in envdir with python versions
rmvenv     : delete a virtual environment, asks first (usage: rmvenv <name>)
regvenv    : register a venv as a jupyter kernel, needs ipykernel (usage: regvenv <name>)
unset_venv : unset virtual environment variables

=== VIM/NEOVIM ===
setc       : set vim keybindings to colemak layout
setq       : set vim keybindings to qwerty layout
set_vim    : configure vim mode with clipboard integration
nvim       : launch neovim with proper environment
tn         : tmux -> neovim
tnt        : tmux -> neovim -> terminal
tntc       : tmux -> neovim -> terminal -> claude
nt         : neovim -> terminal
ntc        : neovim -> terminal -> claude

=== AI ===
ccc    : claude --continue
ccr    : claude --resume

=== MOUNTING & FILE SYSTEMS ===
mnt             : mount with user permissions, auto-detects type (usage: mnt [-t type] <device> <path>)
tar_all_dirs    : tar all directories in source to destination
ssh_mount       : mount remote directory via sshfs (usage: ssh_mount <user@host:path> <name>)
ssh_unmount     : unmount sshfs directory (usage: ssh_unmount <name>)

=== IMPORTANT VARIABLES ===
envdir          : path to python virtual environments
uv_python_dir   : where uv installs python versions
uv_cache_dir    : uv download cache, keep on the same drive as envdir
NEOVIM_PATH     : path to neovim configuration
is_arch         : boolean indicating if running on Arch Linux"'

alias src='source ~/.bashrc'

shorten_path() {
    _shorten_path_helper() {
        local max_path_len=15
        local p="$PWD"
        p="${p/#$HOME/\~}"

        if [ ${#p} -gt $max_path_len ]; then
            echo "[...${p: -$((max_path_len-3))}]"
        else
            echo "[$p]"
        fi
    }

    export PS1='\[\033[0m\]$(_shorten_path_helper)\[\033[0;36m\] \$ \[\033[0m\]'
}

hide_path() {
    # truncate path to $
    clear
    export PS1="\[\033[0;36m\]\$ \[\033[0m\]"
}
alias hp='hide_path'

show_path() {
    # show full path
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[00;31m\]\u@\h\[\033[00m\]:\[\033[01;30m\]\w\[\033[00m\]\$ '
}
alias sp='shorten_path'


mnt() {
    # mount a device with user permissions
    # usage: mnt [-t type] <device> <path>
    # type is auto-detected if not given
    local type=""
    if [ "$1" = "-t" ]; then
        type="$2"
        shift 2
    fi

    if [ $# -ne 2 ]; then
        echo "usage: mnt [-t type] /dev/sdXY /mnt/destination"
        return 1
    fi

    if [ ! -e "$1" ]; then
        echo "device: $1 doesn't exist"
        return 1
    fi

    if [ ! -d "$2" ]; then
        echo "path: $2 doesn't exist"
        return 1
    fi

    [ -z "$type" ] && type=$(lsblk -no FSTYPE "$1")

    # uid/gid only apply to filesystems without unix permissions
    case "$type" in
        vfat|fat32|exfat|ntfs|ntfs3)
            [ "$type" = "fat32" ] && type="vfat"
            sudo mount -t "$type" -o uid=$(id -u),gid=$(id -g) "$1" "$2"
            ;;
        *)
            sudo mount ${type:+-t "$type"} "$1" "$2"
            ;;
    esac
}

tar_all_dirs() {
    local source_dir="$1"
    local dest_dir="$2"

    # check if both arguments are provided
    if [ -z "$source_dir" ] || [ -z "$dest_dir" ]; then
        echo "Usage: tar_all_dirs <source_directory> <destination_directory>"
        echo "Example: tar_all_dirs /mnt/root-btrfs/snapshots /mnt/usb/backup_dir/"
        return 1
    fi

    # check if source directory exists
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory $source_dir does not exist"
        return 1
    fi

    # create destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # check if destination directory was created successfully
    if [ ! -d "$dest_dir" ]; then
        echo "Error: Cannot create or access destination directory $dest_dir"
        return 1
    fi

    # find all directories in source and store in array
    dirs_to_zip=()
    while IFS= read -r -d '' dir; do
        dirs_to_zip+=("$(basename "$dir")")
    done < <(find "$source_dir" -maxdepth 1 -type d -not -path "$source_dir" -print0)

    # check if any directories were found
    if [ ${#dirs_to_zip[@]} -eq 0 ]; then
        echo "No directories found in $source_dir"
        return 1
    fi

    # display directories that will be zipped
    echo "Found ${#dirs_to_zip[@]} directories to zip:"
        echo "----------------------------------------"
        for dir_name in "${dirs_to_zip[@]}"; do
            echo "  • $dir_name"
        done
        echo "----------------------------------------"
        echo "Source: $source_dir"
        echo "Destination: $dest_dir"
        echo ""

        # ask for confirmation
        read -p "Do you want to proceed with zipping these directories? (y/N): " -n 1 -r
        echo    # move to a new line

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            return 0
        fi

        echo ""
        echo "Starting to zip directories..."
        echo "----------------------------------------"

        # loop through each directory and create tar.gz
        for dir_name in "${dirs_to_zip[@]}"; do
            echo "Zipping: $dir_name"

            # create tar.gz with same name as the directory (with progress bar)
            sudo tar -czf - -C "$source_dir/$dir_name" . | pv > "$dest_dir/${dir_name}.tar.gz"

            # check if tar command was successful
            if [ $? -eq 0 ]; then
                echo "  ✓ Successfully created ${dir_name}.tar.gz"
            else
                echo "  ✗ Failed to create ${dir_name}.tar.gz"
            fi
            echo ""
        done

        echo "----------------------------------------"
        echo "Zipping completed!"
        echo "Files saved to: $dest_dir"
    }

# i wrap this in a function e() which is easier for me to press. see at the top
# of the neovim section
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd z)"
# //==========================================//
# //==========================================//
#
# //==========================================//
# //================= neovim =================//
# here you find tools and functions related to neovim
NEOVIM_PATH="$HOME/.config/nvim"

function cd() {
    builtin cd "$@"
    notify_nvim
}

function e() {
    # zoxide wrapper
    z "$@"
    notify_nvim
}

nvim() {
    if [[ "$VIRTUAL_ENV" != "neovim" ]]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            deactivate
        fi
        if [ -d "$envdir/neovim" ]; then
            actvenv 'neovim'
        fi
    fi
    command nvim "$@"
}

notify_nvim() {
    # send specific signal to neovim if this terminal is spawned inside it
    if [ -n "$NVIM" ]; then
        printf '\033]51;%s\007' $(pwd)
    fi
}

# --- launch shortcuts ---
# t = tmux, n = neovim, t (after n) = :term, c = claude
# order matters: tmux -> neovim -> terminal -> claude

nt() {
    # neovim with a terminal open
    nvim -c 'terminal' -c 'startinsert' "$@"
}

ntc() {
    # neovim -> terminal -> claude (quitting claude leaves you in the terminal)
    nvim -c 'terminal' \
         -c 'call chansend(b:terminal_job_id, "claude\r")' \
         -c 'startinsert' "$@"
}

_tmux_run() {
    # start tmux and type $1 into its shell so bash functions (nvim venv) work
    # and you land back in a tmux shell afterwards. if already in tmux, just
    # run it here instead of nesting.
    if [ -n "$TMUX" ]; then
        eval "$1"
    else
        tmux new-session \; send-keys "$1" C-m
    fi
}

tn()   { _tmux_run "nvim $*"; }  # tmux -> neovim
tnt()  { _tmux_run "nt $*"; }    # tmux -> neovim -> terminal
tntc() { _tmux_run "ntc $*"; }   # tmux -> neovim -> terminal -> claude
# //==========================================//
# //==========================================//
#
# //==========================================//
# //================== vim ===================//
# for in terminal vim
export EDITOR=vim
export VISUAL=vim

# layout settings persist in file below
EDITOR_SETTINGS_DIR="${HOME}/.config/editor"
LAYOUT_FILE="${EDITOR_SETTINGS_DIR}/layout"
mkdir -p "$EDITOR_SETTINGS_DIR"

set_vim() {
    set -o vi

    local paste_cmd copy_cmd

    if command -v wl-paste >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
        paste_cmd='wl-paste'
        copy_cmd='wl-copy'
    elif command -v xclip >/dev/null 2>&1; then
        paste_cmd='xclip -selection clipboard -o'
        copy_cmd='xclip -selection clipboard'
    else
        paste_cmd=''
        copy_cmd=''
    fi

    if [[ -n "$paste_cmd" && -n "$copy_cmd" ]]; then
        bind -m vi-command -x "\"p\": CLIP=\$($paste_cmd | sed -z 's/\r//g; s/\n/;\n/g; s/[;\n]*$//') && READLINE_LINE=\"\${READLINE_LINE:0:READLINE_POINT+1}\${CLIP}\${READLINE_LINE:READLINE_POINT+1}\" && READLINE_POINT=\$((READLINE_POINT + \${#CLIP}))"
        bind -m vi-command -x "\"yy\": printf '%s' \"\$READLINE_LINE\" | $copy_cmd"
    fi

    colemak_binds=(
        # lowercase movement keys
        'k:backward-char'          # h -> k (left)
        'n:next-history'           # j -> n (down)
        'e:previous-history'       # k -> e (up)
        'i:forward-char'          # l -> i (right)
        # uppercase movement keys
        'K:backward-word'         # H -> K
        'N:beginning-of-history'  # J -> N
        'E:end-of-history'       # K -> E
        'I:forward-word'         # L -> I
        # reverse mappings
        'h:vi-search-again'      # n -> h (find next)
        'j:vi-end-word'         # e -> j
        'l:vi-insertion-mode'   # i -> l
        'H:vi-rev-repeat-search' # N -> H
        'J:vi-end-word'         # E -> J
        'L:vi-replace'          # I -> L
    )

    qwerty_binds=(
        'h:backward-char'
        'j:next-history'
        'k:previous-history'
        'l:forward-char'
        'H:backward-word'
        'J:beginning-of-history'
        'K:end-of-history'
        'L:forward-word'
        'n:vi-search-again'
        'e:vi-end-word'
        'i:vi-insertion-mode'
        'N:vi-rev-repeat-search'
        'E:vi-end-word'
        'I:vi-replace'
    )

    if [ -f "$LAYOUT_FILE" ]; then
        key_layout=$(cat "$LAYOUT_FILE" 2>/dev/null | tr -d '\n\r')

        # bind colemak
        if [[ "$key_layout" == "colemak" ]]; then
            for binding in "${colemak_binds[@]}"; do
                bind -m vi-command "$binding"
            done

        # default binds
        elif [[ "$key_layout" == "qwerty" ]]; then
            for binding in "${qwerty_binds[@]}"; do
                bind -m vi-command "$binding"
            done

        fi
    fi
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

# WARNING: this function is dangerous because it will not use root's .vimrc
# make sure that is what you want!
function sudo() {
    if [[ "$1" == "vi" || "$1" == "vim" ]]; then
        command sudo -E vim "${@:2}"
    elif [[ "$1" == "-E" && "$2" == "vi" ]]; then
        command sudo -E vim "${@:3}"
    else
        command sudo "$@"
    fi
}

alias vi='vim'
# //==========================================//
# //==========================================//
#
# //================ welcome =================//
# //==========================================//
# add colors here
CUSTOM_PINK='\e[38;2;228;171;212m'
CUSTOM_GRAY='\e[38;2;196;189;210m'
NC='\e[0m'

# configure these as you like
CENTERED_WELCOME=1
WELCOME_COLOR=$CUSTOM_GRAY

# change this to a different location if you want
ascii_path="$HOME/.dotfiles/ascii_art/"
ascii_art="reaper2.txt"

# function that prints given text centered in the terminal for whatever width.
center_text() {
    local should_center=$CENTERED_WELCOME

    if [[ $should_center -eq 0 ]]; then
        cat -
        return
    fi

    term_width=$(tput cols)

    # read input line by line while preserving colors
    while IFS= read -r line; do
        # strip ansi color codes for width calculation
        plain_line=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*m//g')
        # calculate padding
        padding=$(( (term_width - ${#plain_line}) / 2 ))
            # add padding before the line
        printf "%${padding}s%s\n" "" "$line"
    done
}

# --- binary rain cat welcome ---
CAT_ART_FILE="${ascii_path}cat.txt"
CAT_FULL_W=109
CAT_FULL_H=39
CAT_MIN_W=50
CAT_MIN_H=35
CAT_CENTER_COL=54  # horizontal center of the art

show_cat() {
    local term_w term_h
    term_w=$(tput cols)
    term_h=$(tput lines)

    [[ $term_w -lt $CAT_MIN_W || $term_h -lt $CAT_MIN_H ]] && return

    local art_w art_h
    art_w=$(( term_w < CAT_FULL_W ? term_w : CAT_FULL_W ))
    art_h=$(( term_h - 2 < CAT_FULL_H ? term_h - 2 : CAT_FULL_H ))

    local half=$(( art_w / 2 ))
    local col_start=$(( CAT_CENTER_COL - half ))
    local col_end=$(( col_start + art_w - 1 ))
    [[ $col_start -lt 0 ]] && col_start=0 && col_end=$(( art_w - 1 ))
    [[ $col_end -ge $CAT_FULL_W ]] && col_end=$(( CAT_FULL_W - 1 )) && col_start=$(( col_end - art_w + 1 ))
    [[ $col_start -lt 0 ]] && col_start=0
    local visible_w=$(( col_end - col_start + 1 ))

    local pad=$(( (term_w - visible_w) / 2 ))
    local pad_str
    pad_str=$(printf "%${pad}s" "")

    echo
    while IFS= read -r line; do
        echo "${pad_str}${line}"
    done < <(python3 -c "
lines = open('$CAT_ART_FILE').read().splitlines()
for l in lines[:${art_h}]:
    l = l + ' ' * (${CAT_FULL_W} - len(l))
    print(l[${col_start}:${col_end}+1])
")
    echo
}

# print the welcome message , whether fastfetch or ascii art
welcome() {
    if command -v fastfetch >/dev/null 2>&1; then
        echo; echo
        if [ -n "$NVIM" ]; then
            # nvim's number column eats a column, so draw one column narrower
            fastfetch --logo-padding-right 3
        else
            fastfetch
        fi
    elif [ -f "$CAT_ART_FILE" ]; then
        show_cat
    elif [ -f "$ascii_path$ascii_art" ]; then
        echo; echo
        echo -e "${WELCOME_COLOR}$(cat "$ascii_path$ascii_art")${NC}" | center_text
    fi
    echo; echo
}
# //==========================================//
# //==========================================//
#
# //================= git ====================//
# //==========================================//
pushall() {
    for remote in $(git remote); do
        git push $remote master
    done
}

pullall() {
    for remote in $(git remote); do
        git pull $remote master
    done
}
# //==========================================//
# //==========================================//
#
# //================ python ==================//
# //==========================================//
alias python='python3'


invenv() { # check if we are in a virtual environment
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "not in a virtual environment"
    else
        echo "in a virtual environment located at: $VIRTUAL_ENV"
    fi
}

actvenv() {
    if [ -z "$1" ]; then
        echo "error: no environment name provided"
        return 1
    fi
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "in a virtual environment already at: $VIRTUAL_ENV. deactivate first."
    fi
    path="$envdir/$1"
    if [ -d "$path" ]; then
        source "$path/bin/activate"
    else
        echo "error: environment not found"
    fi
}

mkvenv() {
    # create a virtual environment in $envdir with uv
    # $1: name of the environment
    # $2: version of python to use (ex. 3.13). uv downloads it if it isn't installed.
    #     if not given, uses the newest python uv has installed, or downloads the latest.
    # packages are installed with `uv pip install`, there is no pip inside the venv

    if [ -z "$1" ]; then
        echo "error: no environment name provided"
        return 1
    fi
    if [[ "$1" == */* || "$1" == .* ]]; then
        echo "error: give the environment name, not a path"
        return 1
    fi

    local path="$envdir/$1"

    if [ -d "$path" ]; then
        echo "error: environment already exists"
        return 1
    fi

    local version="$2" desc py
    if [ -z "$version" ]; then
        py=$(uv python find 2>/dev/null)
        if [ -n "$py" ]; then
            desc="$("$py" --version)"
        else
            desc="latest python (will be downloaded)"
        fi
        echo "no version specified, using $desc (y) ?"
    else
        echo "create environment with python $version (y) ?"
    fi
    read response
    if [ "$response" != "y" ]; then
        echo "rejected"
        return 0
    fi

    if [ -z "$version" ]; then
        uv venv "$path" || return 1
    else
        uv venv --python "$version" "$path" || return 1
    fi
    echo "virtual environment created at $path"
}

upvenv() {
    # rebuild a virtual environment in $envdir on another python version, keeping its packages
    # $1: name of the environment
    # $2: python version to move to (ex. 3.14)
    # works on broken venvs too, since the package list is read straight from site-packages.
    # the old venv is kept as <name>.old until the new one works.

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "usage: upvenv <name> <python_version>"
        return 1
    fi
    if [[ "$1" == */* || "$1" == .* ]]; then
        echo "error: give the environment name, not a path"
        return 1
    fi

    local path="$envdir/$1"
    local old="$path.old"

    if [ ! -d "$path" ]; then
        echo "error: environment not found"
        return 1
    fi
    if [ "$VIRTUAL_ENV" == "$path" ]; then
        echo "error: environment is active. deactivate first."
        return 1
    fi
    if [ -e "$old" ]; then
        echo "error: $old already exists. remove it first."
        return 1
    fi

    # read name==version of every package in the old venv, skipping pip.
    # uses uv's python since the venv's own python may be gone.
    local reqs
    reqs=$(mktemp --suffix=-"$1"-reqs.txt) || return 1
    uv run --no-project --python "$2" python -I -c '
import glob, sys, importlib.metadata as m
paths = glob.glob(sys.argv[1] + "/lib/python*/site-packages")
pkgs = {d.metadata["Name"]: d.version for d in m.distributions(path=paths)}
for name in sorted(pkgs, key=str.lower):
    if name.lower() != "pip":
        print(f"{name}=={pkgs[name]}")
' "$path" > "$reqs" || { echo "error: could not read packages"; return 1; }

    echo "packages in $1 ($(wc -l < "$reqs")), saved to $reqs:"
    tr '\n' ' ' < "$reqs"
    echo
    echo "rebuild $1 on python $2 (y) ?"
    read response
    if [ "$response" != "y" ]; then
        echo "rejected"
        return 0
    fi

    mv "$path" "$old" || return 1
    if ! uv venv --python "$2" "$path"; then
        echo "error: could not create venv, restoring old one"
        command rm -rf -- "$path"
        mv "$old" "$path"
        return 1
    fi

    if [ -s "$reqs" ] && ! uv pip install --python "$path" -r "$reqs"; then
        echo "install with pinned versions failed, retry with newest versions instead (y) ?"
        read response
        if [ "$response" != "y" ] || ! uv pip install --python "$path" -r <(sed 's/==.*//' "$reqs"); then
            echo "error: install failed, restoring old venv"
            command rm -rf -- "$path"
            mv "$old" "$path"
            return 1
        fi
    fi

    echo "$1 rebuilt on python $2. delete old venv at $old (y) ?"
    read response
    if [ "$response" == "y" ]; then
        if command rm -rf -- "$old"; then
            echo "old venv deleted"
        else
            echo "error: could not fully delete $old. close anything still using it (ex. a running neovim) and remove it by hand"
        fi
    else
        echo "kept old venv at $old"
    fi
}

lsvenv() {
    # list the virtual environments in $envdir with their python version
    # the active environment is marked with *

    if [ ! -d "$envdir" ]; then
        echo "error: env directory not found: $envdir"
        return 1
    fi

    echo "envs in $envdir:"
    local env_path name version mark linked
    for env_path in "$envdir"/*/; do
        [ -d "$env_path" ] || continue
        env_path="${env_path%/}"
        name="${env_path##*/}"
        if [ -f "$env_path/pyvenv.cfg" ]; then
            # virtualenv writes 3.13.7.final.0, uv writes just 3.14
            version=$(sed -n 's/^version_info = \([0-9]*\.[0-9]*\(\.[0-9]*\)\?\).*/\1/p; s/^version = //p' "$env_path/pyvenv.cfg" | head -n 1)
            linked=$(readlink -f "$env_path/bin/python")
            # uv pythons live in cpython-X.Y.Z-..., use that to show the full version
            if [[ "$linked" =~ /cpython-([0-9]+\.[0-9]+\.[0-9]+)[^/]*/bin/ ]]; then
                version="${BASH_REMATCH[1]}"
            fi
            # the python it links to is gone, or is now a different minor version
            # (ex. /usr/bin/python moved 3.13 -> 3.14 in a system upgrade)
            if [ ! -e "$linked" ]; then
                version="$version (broken, python missing)"
            elif [[ "${linked##*/}" == python3.* && "${linked##*/python}" != "$(cut -d. -f1-2 <<< "$version")" ]]; then
                version="$version (broken, now runs ${linked##*/python})"
            fi
        else
            version="(not a venv)"
        fi
        mark=" "
        [ "$VIRTUAL_ENV" == "$env_path" ] && mark="*"
        printf "%s %-20s %s\n" "$mark" "$name" "$version"
    done
}

rmvenv() {
    # delete a virtual environment from $envdir after confirmation
    # $1: name of the environment

    if [ -z "$1" ]; then
        echo "error: no environment name provided"
        return 1
    fi
    if [[ "$1" == */* || "$1" == "." || "$1" == ".." ]]; then
        echo "error: give the environment name, not a path"
        return 1
    fi

    local path="$envdir/$1"

    if [ ! -d "$path" ]; then
        echo "error: environment not found"
        return 1
    fi
    if [ "$VIRTUAL_ENV" == "$path" ]; then
        echo "error: environment is active. deactivate first."
        return 1
    fi

    echo "delete environment at $path (y) ?"
    read response
    if [ "$response" == "y" ]; then
        if command rm -rf -- "$path"; then
            echo "environment deleted"
        else
            echo "error: could not fully delete $path. close anything still using it (ex. a running neovim) and try again"
            return 1
        fi
    else
        echo "rejected"
        return 0
    fi
}

regvenv() {
    # register a virtual environment as a jupyter kernel (for molten, jupyter, etc.)
    # $1: name of the environment, also used as the kernel name
    # only registers if the venv's python runs and has ipykernel installed.
    # writes ~/.local/share/jupyter/kernels/<name>/kernel.json, nothing is installed.
    # running it again re-registers (ex. after upvenv), undo with: jupyter kernelspec uninstall <name>

    if [ -z "$1" ]; then
        echo "usage: regvenv <name>"
        return 1
    fi
    if [[ "$1" == */* || "$1" == .* ]]; then
        echo "error: give the environment name, not a path"
        return 1
    fi

    local path="$envdir/$1"
    local py="$path/bin/python"

    if [ ! -d "$path" ]; then
        echo "error: environment not found"
        return 1
    fi
    if ! "$py" -c '' 2>/dev/null; then
        echo "error: $py does not run (broken venv? see lsvenv)"
        return 1
    fi
    if ! "$py" -c 'import ipykernel' 2>/dev/null; then
        echo "error: ipykernel is not installed in $1. install it with:"
        echo "  uv pip install --python $path ipykernel"
        return 1
    fi

    local kernel_dir="$HOME/.local/share/jupyter/kernels/$1"
    [ -d "$kernel_dir" ] && echo "kernel $1 already registered, updating it"

    "$py" -m ipykernel install --user --name "$1" --display-name "$1" || return 1
}

unset_venv() {
    unset VIRTUAL_ENV
    if [ -n "$PATH" ]; then
        # remove all the env paths
        export PATH=$(echo $PATH | tr ':' '\n' | grep -v "/.envs/" | tr '\n' ':' | sed 's/:$//')
    fi
}
# //==========================================//
# //==========================================//
#
# //================= sshfs ==================//
# //==========================================//
ssh_mount() {
    # create a remote mount
    # usage: ssh_mount <user@address:path/to/dir> <mount_name>
    # if <mount_name> doesn't exist in ~/remote-mounts then creates it and starts the mount with sshfs
    mkdir -p ~/remote-mounts/$2
    sshfs $1 ~/remote-mounts/$2
}

ssh_unmount() {
    # unmount a mounted ssh filesystem
    if [ ! -d ~/remote-mounts/$1 ]; then
        echo "no such folder ~/remote-mounts/$1"
    else
        fusermount -u ~/remote-mounts/$1
    fi
}
# //==========================================//
# //==========================================//
#
# //================== cuda ==================//
# //==========================================//

# 1080ti support babyy
alias nv='nvcc -ccbin g++-14 -arch=sm_61 -Wno-deprecated-gpu-targets'
# NOTE: this is for my local PC. make sure you have cuda 12.9.1 and gcc14

# //==========================================//
# //==========================================//
#
# //================= conda ==================//
# //==========================================//

function set_miniconda() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null 2>&1)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup" 2>/dev/null
    else
        if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/opt/miniconda3/etc/profile.d/conda.sh" 2>/dev/null
        else
            export PATH="/opt/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    if [ -n "$CONDA_PREFIX" ]; then
        export PATH="$CONDA_PREFIX/bin:$PATH"
    fi
}

# //==========================================//
# //==========================================//
#
# //=================== ai ===================//
# //==========================================//

codex() {
    ~/.dotfiles/dotfiles/.codex/run_codex.sh "$@"
}

alias ccc='claude -c' # claude code continue
alias ccr='claude -r' # claude code resume

# //==========================================//
# //==========================================//
#
# //================= local ==================//
# //==========================================//

if [[ -f "$HOME/.bash_local" ]]; then
    source "$HOME/.bash_local"
fi

# //==========================================//
# //==========================================//
#
# //================= script ==================//
# //==========================================//
# anything that needs to be run at the end
hide_path
unset_venv
remove_path_duplicates
welcome
set_vim
notify_nvim
