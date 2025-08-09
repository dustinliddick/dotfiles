# Installation Guide

## Quick Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Run the installation script

```bash
./install.sh
```

The script will:
- Backup your existing dotfiles to `~/.dotfiles_backup_TIMESTAMP`
- Install Homebrew (macOS only)
- Install packages from the Brewfile
- Create symbolic links to all configuration files
- Set proper permissions

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
~/.dotfiles/
├── install.sh              # Main installation script
├── backup.sh               # Backup script for existing dotfiles
├── Brewfile                # Homebrew packages
├── .bashrc                 # Bash configuration
├── .bash_profile           # Bash profile
├── .zshrc                  # Zsh configuration
├── .gitconfig              # Git configuration
├── .gitignore_global       # Global gitignore
├── .vimrc                  # Vim configuration
├── .tmux.conf              # Tmux configuration
├── .ssh/
│   └── config              # SSH configuration template
├── docs/                   # Documentation
└── README.md               # Main documentation
```

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