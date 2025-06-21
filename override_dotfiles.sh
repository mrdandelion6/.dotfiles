# find all files recursively in ~/.dotfiles/dotfiles
find ~/.dotfiles/dotfiles -type f | while read -r dotfile; do
  # get the relative path from ~/.dotfiles/dotfiles
  rel_path=${dotfile#~/.dotfiles/dotfiles/}

  # check if rel_path is in ignored.txt (skipping commented lines)
  if [ -f ~/.dotfiles/ignore.txt ]; then
      is_ignored=0
      while IFS= read -r ignore_pattern || [ -n "$ignore_pattern" ]; do
        # skip empty lines and comments
        [[ -z "$ignore_pattern" || "$ignore_pattern" =~ ^[[:space:]]*# ]] && continue

        # check if rel_path matches the pattern
        if [[ "$rel_path" == "$ignore_pattern" ]]; then
          is_ignored=1
          echo "Ignoring: $rel_path (matched pattern: $ignore_pattern)"
          break
        fi
      done < ignore.txt
  fi

  # skip this file if it's in the ignore list
  [[ $is_ignored -eq 1 ]] && continue

  # create the target directory in home if it doesn't exist
  target_dir=$(dirname ~/"$rel_path")
  mkdir -p "$target_dir"

  # remove the file if it exists
  rm -f ~/"$rel_path"

  # create symbolic link
  ln -s "$dotfile" ~/"$rel_path"
  echo "Linked: $dotfile -> ~/$rel_path"
done
