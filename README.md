# dotfiles

A comprehensive collection of configuration files for macOS and Linux development environments.

## Features

- **Shell Configuration**: Zsh and Bash configurations with useful aliases and functions
- **Git Configuration**: Comprehensive git config with helpful aliases and security settings
- **Editor Configuration**: Vim configuration with sensible defaults
- **Terminal Multiplexer**: Tmux configuration for enhanced terminal productivity
- **Package Management**: Brewfile for automated macOS package installation
- **SSH Configuration**: Secure SSH client configuration template
- **Automated Installation**: One-command setup with backup of existing files

## Quick Start

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

## What's Included

### Shell Configuration
- `.zshrc` - Zsh configuration with Oh My Zsh, Powerlevel10k theme, and useful plugins
- `.bashrc` - Bash configuration with aliases and functions
- `.bash_profile` - Bash profile for login shells

### Git Configuration
- `.gitconfig` - Git configuration with aliases and security settings
- `.gitignore_global` - Global gitignore for common files and directories

### Editor Configuration
- `.vimrc` - Vim configuration with sensible defaults and key bindings
- `.tmux.conf` - Tmux configuration with vim-like key bindings

### Package Management
- `Brewfile` - Homebrew bundle for automated package installation (macOS)

### SSH Configuration
- `.ssh/config` - SSH client configuration template with security best practices

## Customization

### Git Configuration
Before using, update the git configuration with your details:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Or edit `.gitconfig` directly and replace the placeholder values.

### SSH Configuration
The SSH config is a template. Uncomment and modify the host entries as needed for your servers and services.

### Shell Configuration
The shell configurations include:
- Useful aliases for common commands
- Git aliases for efficient version control
- Docker aliases for container management
- Custom functions for productivity
- Environment variable setup for development tools

## Manual Setup Steps

### Oh My Zsh (for Zsh users)
If not already installed:

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Powerlevel10k Theme
Install the theme:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Run the configuration wizard:

```bash
p10k configure
```

### Zsh Plugins
Install useful plugins:

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Node Version Manager (NVM)
Install NVM for Node.js version management:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### Python Environment Management
Install pyenv for Python version management:

```bash
curl https://pyenv.run | bash
```

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
└── README.md               # This file
```

## Troubleshooting

### Permission Issues
If you encounter permission issues with SSH:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
```

### Homebrew Installation Issues
If Homebrew fails to install, try installing it manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Shell Not Changing
If your default shell isn't changing to Zsh:

```bash
chsh -s $(which zsh)
```

## Backup and Restore

The installation script automatically backs up existing dotfiles. To restore:

```bash
cp ~/.dotfiles_backup_TIMESTAMP/* ~/
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the installation on a fresh system
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
