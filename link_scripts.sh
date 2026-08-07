#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPTS_DIR:-$DOTFILES_DIR/scripts}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

if [[ ! -d "$SCRIPTS_DIR" ]]; then
  echo "Scripts directory not found: $SCRIPTS_DIR" >&2
  exit 1
fi

mkdir -p "$BIN_DIR"

confirm_override() {
  local target=$1
  local answer

  if [[ ! -t 0 ]]; then
    echo "Skipping existing target without prompt: $target"
    return 1
  fi

  while true; do
    read -r -p "Target exists: $target. Override or skip? [o/S] " answer
    case "$answer" in
      [oO]|[oO][vV][eE][rR][rR][iI][dD][eE])
        return 0
        ;;
      ""|[sS]|[sS][kK][iI][pP])
        return 1
        ;;
      *)
        echo "Please answer 'o' to override or 's' to skip."
        ;;
    esac
  done
}

found=0

while IFS= read -r -d '' script; do
  found=1

  script_name="$(basename -- "$script")"
  link_name="${script_name%.sh}"

  if [[ -z "$link_name" ]]; then
    echo "Skipping script with empty link name: $script"
    continue
  fi

  target="$BIN_DIR/$link_name"

  if [[ -L "$target" && "$(readlink -- "$target")" == "$script" ]]; then
    echo "Already linked: $target -> $script"
    continue
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -d "$target" && ! -L "$target" ]]; then
      echo "Skipping existing directory: $target"
      continue
    fi

    if ! confirm_override "$target"; then
      echo "Skipped: $target"
      continue
    fi

    rm -f -- "$target"
  fi

  ln -s -- "$script" "$target"
  echo "Linked: $target -> $script"

  if [[ ! -x "$script" ]]; then
    echo "Warning: source is not executable: $script"
  fi
done < <(find "$SCRIPTS_DIR" -type f -print0 | sort -z)

if [[ "$found" -eq 0 ]]; then
  echo "No scripts found in: $SCRIPTS_DIR"
fi
