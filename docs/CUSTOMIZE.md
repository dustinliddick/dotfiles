# Customization Guide

## Initial Configuration

### Git Configuration
Before using, update the git configuration with your details:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Or edit `.gitconfig` directly and replace the placeholder values.

### SSH Configuration
The SSH config is a template. Uncomment and modify the host entries as needed for your servers and services.

## Shell Configuration Features

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
**Important**: The dotfiles use Powerlevel10k theme, which requires initial setup.

If Powerlevel10k isn't installed automatically, install it manually:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

**Required**: Run the configuration wizard to set up your prompt style:

```bash
p10k configure
```

This wizard will guide you through customizing your prompt appearance. You can run it anytime to reconfigure.

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

## Configuration Files Overview

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