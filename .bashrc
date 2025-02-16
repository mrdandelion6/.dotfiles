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
# //================ dotfiles ================//
# //==========================================//
# latex
latex_dir=~/.latex

# remote mounts
remote_mounts=~/.remote_mounts
# //==========================================//
# //==========================================//
#
# //============ configure device ============//
# //==========================================//
# configure device
# default configs
default_win_envdir="/mnt/c/envs"
case "$(hostname)" in
    "Acer-DK")
        win_envdir="/mnt/d/envs"
        ;;
    "FS-Laptop")
        win_envdir=$default_win_envidir
        ;;
    *)
        # default case if no match
        echo ".bashrc does not recognize this device name: $(hostname). using default configurations."
        win_envdir=$default_win_envdir
        ;;
esac
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
alias als='echo "als : list custom alias and functions
ls : ls-lah
gin : gcc -w -o notes notes.c
ginc : rm notes main a.out notes.exe main.exe
bash_ref : . ~/.bashrc
bash_pull : cp ~/.bashrc
bash_push : push .bashrc from pwd to ~
lc <text> : print cool text
welcome : print welcome message
pushall : push to all repos
pullall : pull from all repos
hp : hide shell path
sp : show shell path
envdir : variable holds path to python environments directory"'

hp() {
    # truncate path to $
    clear
    export PS1="\[\033[0;36m\]\$ \[\033[0m\]"
}

sp() {
    # show full path
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[00;31m\]\u@\h\[\033[00m\]:\[\033[01;30m\]\w\[\033[00m\]\$ '
}

alias src='source ~/.bashrc'
# //==========================================//
# //==========================================//
#
# //==========================================//
# //================= neovim =================//
# here you find tools and functions related to neovim
NEOVIM_PATH="$HOME/.config/nvim/"

nvim() {
    if [[ "$VIRTUAL_ENV" != "neovim" ]]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            deactivate
        fi
        actenv 'neovim'
    fi
    command nvim "$@"
}

notify_nvim() {
    printf '\033]51;%s\007' $(pwd)
}

function cd() {
    builtin cd "$@"
    if [ -n "$NVIM" ]; then
        notify_nvim
    fi
}
# //==========================================//
# //==========================================//
#
# //==========================================//
# //================== vim ===================//
# for in terminal vim
VIM_LOCAL_SETTINGS="$NEOVIM_PATH/.localsettings.json"
set_vim() {
    set -o vi
    bind -m vi-command -x '"p": CLIP=$(xclip -selection clipboard -o | tr -d "\n\r") && READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${CLIP}${READLINE_LINE:READLINE_POINT}" && READLINE_POINT=$((READLINE_POINT + ${#CLIP}))'
    bind -m vi-command -x '"yy": printf "%s" "$READLINE_LINE" | xclip -selection clipboard && printf "%s" "$READLINE_LINE" | xclip -selection primary'
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
    if [ -d "$NEOVIM_PATH" ]; then
        [ ! -f "$VIM_LOCAL_SETTINGS" ] && touch "$VIM_LOCAL_SETTINGS"
        key_layout=$(jq -r '.layout // empty' "$VIM_LOCAL_SETTINGS")
        if [[ "$key_layout" == "colemak" ]]; then
            for binding in "${colemak_binds[@]}"; do
                bind -m vi-command "$binding"
            done
        fi
    else
        echo "neovim not set, missing path: $NEOVIM_PATH"
    fi
}
# //==========================================//
# //==========================================//
#
# //================ welcome =================//
# //==========================================//
lolc() {
    # out put an input text with lolcat effect
    local text="$@"
    figlet -f red_phoenix $text | lolcat -S 13
}

# add colors here
CUSTOM_PINK='\e[38;2;228;171;212m'
CUSTOM_GRAY='\e[38;2;196;189;210m'
NC='\e[0m'

# configure these as you like
lolcat_enabled=0
CENTERED_WELCOME=1
WELCOME_COLOR=$CUSTOM_GRAY
ascii_path="${NEOVIM_PATH}bash/ascii_art/" # change this to a different location if you want
ascii_art="reaper2.txt"

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

welcome() {
    echo; echo
    if [ -f "$ascii_path$ascii_art" ]; then
        if [[ $lolcat_enabled -eq 1 ]]; then
            cat "$ascii_path$ascii_art" | lolcat -S 35 -p 100 -F 0.05 | center_text
        else
            echo -e "${WELCOME_COLOR}$(cat "$ascii_path$ascii_art")${NC}" | center_text
        fi
    else
        figlet -f red_phoenix "start" | lolcat -S 13 | center_text
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

envdir=$HOME/.envs

inenv() { # check if we are in a virtual environment
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "not in a virtual environment"
    else
        echo "in a virtual environment located at: $VIRTUAL_ENV"
    fi
}

actenv() {
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

pypath() {
    # return the path of the python executable if it exists.
    # checks pyenv directory only

    if [ -z "$1" ]; then
        echo "error: no version provided"
        return 1
    fi

    path="$PYENV_ROOT/versions/$1/"

    if [ -d "$path" ]; then
        echo "$path"
    else
        echo "error: version not found in pyenv directory"
    fi
}

mkenv() {
    # create a virtual environment in our linux system
    # $1: name of the environment
    # $2: version of python to use
    # note that the environment will be created in ~/envs

    if [ -z "$1" ]; then
        echo "error: no environment name provided"
        return 1
    fi

    path="$envdir/$1"

    if [ -d "$path" ]; then
        echo "error: environment already exists"
        return 1
    fi

    if [ -z "$2" ]; then
        current_version=$(python --version)
        echo "no version specified, using current python version "$current_version" (y) ?"
        read response
        if [ "$response" == "y" ]; then
            virtualenv "$path"
        else
            echo "rejected"
            return 0
        fi
    else
        echo "create environment with python $2 (y) ?"
        read response
        if [ "$response" == "y" ]; then
            python_path="$PYENV_ROOT/versions/$2/"
            if [ -d "$python_path" ]; then
                virtualenv -p "$python_path/bin/python" "$path"
                echo "virtual environment created with version $2"
                return 0
            else
                echo "version not found in pyenv directory, install with pyenv (y) ?"
                read response
                if [ "$response" == "y" ]; then
                    pyenv install $2
                    virtualenv -p "$python_path/bin/python" "$path"
                    echo "virtual environment created with version $2"
                else
                    echo "rejected"
                    return 0
                fi
            fi
        else
            echo "rejected"
            return 0
        fi
    fi
}

unset_env() {
    unset VIRTUAL_ENV
    if [ -n "$PATH" ]; then
        # remove all the env paths
        export PATH=$(echo $PATH | tr ':' '\n' | grep -v "/.envs/", | tr '\n' ':' | sed 's/:$//')
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
# //==========================================//
# //================= latex ==================//
# latex related files
latex_meta="$latex_dir/meta.tex" # typical header stuff to add
latex_build="$latex_dir/build.sh" # build latex in terminal
chmod -f u+x latex_build
# //==========================================//
# //==========================================//
#
# //================== path ==================//
# //==========================================//
# stuff that needs to be added to path
# bin
export PATH=/usr/bin:$PATH

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # this loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # this loads nvm bash_completion

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# cuda
export PATH=/usr/local/cuda-11.8/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# colors
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# rust
. "$HOME/.cargo/env" # sourcing this adds .cargo/bin to path and other things
# //==========================================//
# //==========================================//
#
# //================= script ==================//
# //==========================================//
# anything that needs to be run at the end
hp
unset_env
set_vim
welcome
