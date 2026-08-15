# Usage Guide

## Dotfiles Management

### Updating Dotfiles
To update dotfiles (pull changes from upstream and run [`install.py`](../install.py) again):

```bash
$ dotfiles update
$ dotfiles update --fast          # fast update mode: skip updating {vim,zsh} plugins
```

## Quick Start Guide

After installation, here are some key things to get you started:

### Neovim
- Launch with `nvim` or `vim`
- `:checkhealth` - Verify installation
- `:Lazy` - Plugin manager interface
- `<leader>` key is set to space
- `<leader>ff` - Find files with Telescope
- `<leader>fg` - Live grep with Telescope

### Zsh
- Rich completions and syntax highlighting
- `fzf` integration for history and file search
- Git status in prompt
- Custom aliases in `zsh/zsh.d/alias.zsh`

### Tmux
- Prefix key: `Ctrl-a`
- `prefix + I` - Install plugins
- Session management and window splitting

## Customization

The dotfiles are designed to be customizable. Key areas you might want to modify:

- **Zsh aliases**: Edit `zsh/zsh.d/alias.zsh`
- **Neovim config**: Modify files in `nvim/lua/config/`
- **Terminal colors**: Adjust terminal emulator configs in `config/`
- **Git aliases**: Add custom git aliases in `git/gitconfig`