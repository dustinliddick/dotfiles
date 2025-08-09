# dotfiles

A comprehensive collection of configuration files for macOS and Linux development environments.

## Features

- **Shell Configuration**: Zsh and Bash with useful aliases and functions
- **Git Configuration**: Comprehensive config with helpful aliases and security settings
- **Editor Configuration**: Vim and Tmux configurations
- **Package Management**: Brewfile for automated macOS package installation
- **SSH Configuration**: Secure SSH client configuration template
- **Automated Installation**: One-command setup with backup of existing files

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install-enhanced.sh
```

**Important**: After installation, run `p10k configure` to set up your terminal prompt theme.

Then restart your terminal or `source ~/.zshrc` (or `~/.bashrc`).

## What's Included

- **Shell**: `.zshrc`, `.bashrc`, `.bash_profile`
- **Git**: `.gitconfig`, `.gitignore_global` 
- **Editors**: `.vimrc`, `.tmux.conf`
- **Package Management**: `Brewfile`
- **SSH**: `.ssh/config` template
- **Scripts**: `install.sh`, `backup.sh`

## Documentation

- [Installation Guide](docs/INSTALL.md) - Detailed installation and setup instructions
- [Customization Guide](docs/CUSTOMIZE.md) - How to customize configurations and manual setup steps
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on a fresh system
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
