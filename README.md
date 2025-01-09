# dotfiles

my dotfiles for unix.

## setup

clone this repo in ~
```bash
cd ~
git clone repo
```

backup current dot files
```bash
chmod u+x dotfiles/backup_dotfiles.sh
./dotfiles/backup_dotfiles.sh
```

override current dot files with symbolic link
```bash
chmod u+x dotfiles/override_dotfiles.sh
./dotfiles/override_dotfiles.sh
```
