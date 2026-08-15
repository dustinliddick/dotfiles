# Installation Guide

## Quick Installation

### 1. Clone the repository

```bash
git clone https://github.com/dustin-liddick/dotfiles.git ~/personal_projects/dotfiles
cd ~/personal_projects/dotfiles
```

### 2. Preview what will change

```bash
python3 install.py --dry-run
```

Nothing is modified. Every link is reported as already correct, newly
created, or relinked from somewhere else, so you can spot a surprise before
it touches `$HOME`.

### 3. Run the installation script

```bash
python3 install.py
```

The script will:
- Back up any existing real files it replaces, to `~/.dotfiles_backup_PID`
- Install packages from the Brewfile (macOS only, if Homebrew is present)
- Create symbolic links to all configuration files
- Create `~/.gitconfig.secret` from the template if it does not exist
- Set proper permissions

Re-running is safe: links already pointing at this repo are left alone.

### 3. Restart your terminal or source your shell config

```bash
# For Zsh
source ~/.zshrc

# For Bash
source ~/.bashrc
```

## What Gets Installed

The installation script handles:

- **Backup**: Creates timestamped backup of existing dotfiles
- **Homebrew**: Installs Homebrew package manager (macOS only)
- **Packages**: Installs all packages listed in the Brewfile
- **Symlinks**: Creates symbolic links from your home directory to the dotfiles
- **Permissions**: Sets appropriate file permissions for SSH and other configs

## Directory Structure

```
dotfiles/
├── install.py              # Main installation script
├── backup.sh               # Backup script for existing dotfiles
├── Brewfile                # Homebrew packages
├── zsh/                    # Zsh startup chain (.zshrc, zshenv, zprofile,
│                           #   zlogin, zlogout, zpreztorc, p10k.zsh) + bash
├── git/                    # gitconfig, gitignore
├── vim/                    # .vimrc and vim runtime
├── python/                 # pythonrc, pylintrc, condarc, pycodestyle
├── claude/                 # Claude commands
├── config/                 # XDG configs: nvim, alacritty, bat, kitty,
│                           #   wezterm, tmux
├── docs/                   # Documentation
└── README.md               # Main documentation
```

Note that the shell files live under `zsh/`, not at the repo root. The whole
zsh startup chain is linked, not just `.zshrc`: `zshenv` owns `$PATH` and
`zpreztorc` loads prezto, so a machine missing them lands in a broken shell.

## Backup and Restore

The installation script automatically backs up existing dotfiles to prevent data loss.

### Backup Location
Backups are stored in: `~/.dotfiles_backup_TIMESTAMP`

### Restore from Backup
To restore your original configuration:

```bash
cp ~/.dotfiles_backup_TIMESTAMP/* ~/
```

Replace `TIMESTAMP` with the actual timestamp from your backup directory.