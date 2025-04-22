# find all files recursively in ~/.dotfiles/dotfiles
find ~/.dotfiles/dotfiles -type f | while read -r dotfile; do
  # get the relative path from ~/.dotfiles/dotfiles
  rel_path=${dotfile#~/.dotfiles/dotfiles/}
  
  # create the target directory in home if it doesn't exist
  target_dir=$(dirname ~/"$rel_path")
  mkdir -p "$target_dir"
  
  # remove the file if it exists
  rm -f ~/"$rel_path"
  
  # create symbolic link
  ln -s "$dotfile" ~/"$rel_path"
  echo "Linked: $dotfile -> ~/$rel_path"
done
