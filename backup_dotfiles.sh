mkdir ~/backup_dotfiles
find ~/.dotfiles -maxdepth 1 -type f -name ".*" | while read -r dotfile; do
  # search ~/dotfiles and see if any exist in ~/.
  # back them up in ~/backup_dotfiles if any matches found.
  filename=$(basename "$dotfile")
  if [ -f "$HOME/$filename" ]; then
    cp "$HOME/$filename" ~/backup_dotfiles
  fi
done
