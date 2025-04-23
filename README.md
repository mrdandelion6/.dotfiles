# dotfiles

my dotfiles for unix. does not include [my neovim config](https://github.com/mrdandelion6/faisal.nvim).

## desc

this repository allows you to keep a version control over your dotfiles like `.bashrc`. first it backs up and removes any dotfiles from `~` that are also in this repo. then it creates symbolic links in `~` that point to the dotfiles in this repo.

## setup

clone this repo in ~
```bash
cd ~
git clone git@github.com:mrdandelion6/.dotfiles.git
```

backup current dot files
```bash
chmod u+x dotfiles/backup_dotfiles.sh
.dotfiles/backup_dotfiles.sh
```

override current dot files with symbolic link
```bash
chmod u+x dotfiles/override_dotfiles.sh
.dotfiles/override_dotfiles.sh
```

**optional**: if you want to restore everything from `~/backup_dotfiles/`:
```bash
mv ~/backup_dotfiles/* ~/.dotfiles/
`./override_dotfiles.sh`
```
