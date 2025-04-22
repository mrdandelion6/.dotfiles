find ~/.dotfiles -maxdepth 1 -type f -name ".*" | while read -r dotfile; do
    filename=$(basename "$dotfile")
    rm -f ~/$filename  # remove file if it exists
    ln -s "$dotfile" ~/"$filename"
done
