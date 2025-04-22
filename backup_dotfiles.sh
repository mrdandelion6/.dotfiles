mkdir -p ~/backup_dotfiles

find ~/.dotfiles/dotfiles -type f | while read -r dotfile; do
  # get the relative path from ~/.dotfiles/dotfiles
  rel_path=${dotfile#~/.dotfiles/dotfiles/}
  
  # check if the corresponding file exists in home directory
  if [ -f "$HOME/$rel_path" ]; then
    # create the necessary directory structure in backup_dotfiles
    target_dir=$(dirname ~/backup_dotfiles/"$rel_path")
    mkdir -p "$target_dir"
    
    # copy the file to backup_dotfiles with the same directory structure
    cp "$HOME/$rel_path" "$target_dir"
    echo "Backed up: $HOME/$rel_path"
  fi
done
