# dotfiles

my dotfiles for unix. does not include [my neovim config](https://github.com/mrdandelion6/faisal.nvim).

## desc

this repository is a version control over my dotfiles like `.bashrc`. it also contains some scripts that are nice. you can back up and remove any dotfiles in `~` that are also in this repo. then you can create symbolic links in `~` that point to the dotfiles in this repo.

## setup

clone this repo in home

```bash
cd ~
git clone git@github.com:mrdandelion6/.dotfiles.git
```

**optional**: backup current dot files

```bash
chmod u+x dotfiles/backup_dotfiles.sh
.dotfiles/backup_dotfiles.sh
```

override current dot files with symbolic link

```bash
chmod u+x dotfiles/override_dotfiles.sh
.dotfiles/override_dotfiles.sh
```

**optional**: if you want to restore everything from `~/backup_dotfiles/`

```bash
mv ~/backup_dotfiles/* ~/.dotfiles/
`./override_dotfiles.sh`
```

and if you want to ignore something from being overriden, create a file `ignore.txt` in the root of this repo and add paths to ignore. for example:

```bash
~/.config/wezterm/wezterm.lua
```

## .bashrc deps

some deps

```bash
# general
pacman -S jq gvim inetutils pv

# for python mkenv utilities
pacman -S python python-pip pyenv
pip install --break-system-packages virtualenv

# remote mounting
pacman -S sshfs fusermount

# if using arch
pacman -S yay wl-clipboard
yay -S fastfetch

# if not using arch
sudo apt install xclip

# for neovim , if you want to use the .localsettings.json
pacman -S neovim
cd ~/.config
git clone https://github.com/mrdandelion6/faisal.nvim.git
```

note that you obviously don't need to get neovim but you'll have to edit `~/.bashrc` to remove some echo messages when neovim isn't found.

i use the `.localsettings.json` found in my [neovim repository](https://github.com/mrdandelion6/faisal.nvim#) for keeping track of whether i'm using colemak-dh or qwerty layout. will also change mappings for vim if using `.vimrc` , and for in terminal motions from `set -o vi`.

## local variables

if you want to have local variables to store differing file paths across devices , then create and edit the file `~/.bash_vars`.

here is a sample:

```bash
fall_courses="/mnt/hdd2/study/bsc/y4/fall_courses"
fall_taships="/mnt/hdd2/study/bsc/other/ta-ship/2025-2026/fall_taships"
envdir="/mnt/hdd1/.envs/arch"
```

## more tools i use

to see a list of some tools i use for terminal and dev , see [tools.md](tools.md)
