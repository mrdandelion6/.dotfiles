#!/usr/bin/env bash

DOTFILES_DIR="$HOME/.dotfiles/dotfiles"
IGNORE_FILE="$HOME/.dotfiles/ignore.txt"

# colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# find all files recursively in ~/.dotfiles/dotfiles
find "$DOTFILES_DIR" -type f | while IFS= read -r dotfile; do
  # get the relative path from ~/.dotfiles/dotfiles
  rel_path=${dotfile#"$DOTFILES_DIR"/}
  target="$HOME/$rel_path"

  # check if rel_path is in ignore.txt (skipping commented lines)
  is_ignored=0
  if [ -f "$IGNORE_FILE" ]; then
    while IFS= read -r ignore_pattern || [ -n "$ignore_pattern" ]; do
      # skip empty lines and comments
      [[ -z "$ignore_pattern" || "$ignore_pattern" =~ ^[[:space:]]*# ]] && continue

      # check if rel_path matches the pattern
      if [[ "$rel_path" == "$ignore_pattern" ]]; then
        is_ignored=1
        echo -e "${YELLOW}Ignoring:${RESET} $rel_path (matched pattern: $ignore_pattern)"
        break
      fi
    done < "$IGNORE_FILE"
  fi

  # skip this file if it's in the ignore list
  [[ $is_ignored -eq 1 ]] && continue

  # skip if a symlink to this dotfile already exists
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$dotfile" ]; then
    echo -e "${BLUE}Exists:${RESET} ~/$rel_path"
    continue
  fi

  # create the target directory in home if it doesn't exist
  if ! mkdir -p "$(dirname "$target")"; then
    echo -e "${RED}Error:${RESET} could not create directory for ~/$rel_path" >&2
    continue
  fi

  # remove whatever is there (regular file or a symlink pointing elsewhere)
  if ! rm -f "$target"; then
    echo -e "${RED}Error:${RESET} could not remove ~/$rel_path" >&2
    continue
  fi

  # create symbolic link
  if ln -s "$dotfile" "$target"; then
    echo -e "${GREEN}Linked:${RESET} $dotfile -> ~/$rel_path"
  else
    echo -e "${RED}Error:${RESET} failed to link $dotfile -> ~/$rel_path" >&2
  fi
done
