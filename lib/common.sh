# shared helpers for the scripts in scripts/. this file is sourced by them, never run.
# it lives outside scripts/ so link_scripts.sh doesn't link it into ~/.local/bin
#
# scripts load it with:
#   source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

# where venvs live. normally exported by .bashrc, this is just a fallback
: "${envdir:=$HOME/.envs}"

die() {
    # print an error and exit the script
    echo "error: $*" >&2
    exit 1
}

check_env_name() {
    # $1: venv name. exits if it's empty or looks like a path
    [ -n "$1" ] || die "no environment name provided"
    case "$1" in
        */* | .*) die "give the environment name, not a path" ;;
    esac
}

venv_bin() {
    # $1: venv path. prints the folder holding its python and activate scripts:
    # Scripts/ for venvs made by a windows python (msys2), bin/ everywhere else
    if [ -d "$1/Scripts" ]; then
        echo "$1/Scripts"
    else
        echo "$1/bin"
    fi
}

tmux_run() {
    # start tmux and type $1 into its shell, so shell setup (aliases, venvs) applies and
    # you land back in a tmux shell afterwards. if already in tmux, just run it here
    # instead of nesting
    if [ -n "${TMUX:-}" ]; then
        eval "$1"
    else
        exec tmux new-session \; send-keys "$1" C-m
    fi
}
