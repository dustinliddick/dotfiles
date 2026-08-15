# Updating Your Dotfiles

This guide explains how to keep your dotfiles repository synchronized with your installed configuration files and how to update different aspects of your setup.

## Keeping Repository in Sync with Installed Files

When you make changes to your dotfiles directly (e.g., editing `~/.vimrc`, `~/.zshrc`), you should sync them back to the repository to maintain version control.

### Manual Sync

```bash
# Copy current installed files back to repository
cp ~/.vimrc ~/.dotfiles/vim/vimrc
cp ~/.zshrc ~/.dotfiles/zsh/zshrc  
cp ~/.gitconfig ~/.dotfiles/git/gitconfig
cp ~/.bashrc ~/.dotfiles/bashrc

# Then commit changes
cd ~/.dotfiles
git add -A
git commit -m "Update dotfiles configuration"
```

### Automated Sync Script

You can create a helper script to automate this process:

```bash
#!/bin/bash
# Save as ~/.dotfiles/bin/sync-dotfiles
cd ~/.dotfiles

echo "Syncing dotfiles..."
cp ~/.vimrc vim/vimrc 2>/dev/null || echo "No ~/.vimrc found"
cp ~/.zshrc zsh/zshrc 2>/dev/null || echo "No ~/.zshrc found" 
cp ~/.gitconfig git/gitconfig 2>/dev/null || echo "No ~/.gitconfig found"
cp ~/.bashrc bashrc 2>/dev/null || echo "No ~/.bashrc found"

echo "Files synced. Review changes with 'git status'"
```

## Common Configuration Updates

### Git Configuration

**Main Configuration:**
- File: `git/gitconfig` or edit `~/.gitconfig` directly
- Personal info: Use `~/.gitconfig.secret` (automatically included by main config)

**Example ~/.gitconfig.secret:**
```gitconfig
[user]
    name = Your Name
    email = your.email@example.com

[github]
    user = your-github-username
```

### Zsh Configuration

**Main Configuration:**
- File: `zsh/zshrc`
- Contains shell setup, plugin loading, and main configuration

**Aliases:**
- File: `zsh/zsh.d/alias.zsh`
- Add custom command shortcuts here

**Environment Variables:**
- File: `zsh/zsh.d/envs.zsh`
- Set PATH, exports, and environment configuration

**Work-specific SSH Aliases:**
Add to `zsh/zshrc` or create `zsh/zsh.d/work.zsh`:
```bash
alias server1='ssh -A user@server1.company.com'
alias bastion='ssh -A bastion-host'
```

### Vim/Neovim Configuration

**Vim Configuration:**
- File: `vim/vimrc` or edit `~/.vimrc` directly
- Contains all vim settings, keybindings, and plugin configuration

**Neovim Configuration:**
- Main file: `nvim/init.lua`
- Configuration modules: `nvim/lua/config/`
- Plugin definitions: `nvim/lua/plugins/`

**Common Updates:**
- Leader key: Edit `vim/vimrc` line with `let mapleader=`
- Color scheme: Update colorscheme line in `vim/vimrc`
- Plugins: Add to `vim/plugins.vim` or `nvim/lua/plugins/`

### Terminal Emulator Configuration

**Alacritty:**
- File: `config/alacritty/alacritty.toml`
- Font, colors, window settings

**Kitty:**
- File: `config/kitty/kitty.conf`
- Terminal behavior and appearance

**WezTerm:**
- File: `config/wezterm/wezterm.lua`
- Lua-based configuration

### Bash Configuration

**Main Configuration:**
- File: `bashrc`
- Prompt, exports, and bash-specific settings

**Local Settings:**
- Create `~/.bashrc.local` for machine-specific configuration
- This file is sourced automatically but not tracked in git

## Best Practices

### 1. Test Changes Before Committing
```bash
# Test zsh configuration
zsh -n ~/.zshrc

# Test vim configuration
vim -c 'checkhealth' -c 'qa'
```

### 2. Use Descriptive Commit Messages
```bash
git commit -m "zsh: Add work SSH aliases and update prompt"
git commit -m "vim: Change leader key from comma to space"
git commit -m "git: Add custom aliases for common workflows"
```

### 3. Keep Sensitive Information Separate
- Use `.gitconfig.secret` for personal git info
- Use `.zshrc.local` for machine-specific settings
- Never commit passwords, API keys, or sensitive data

### 4. Backup Before Major Changes
```bash
cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d)
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
```

### 5. Regular Maintenance
```bash
# Update plugins and dependencies
dotfiles update

# Clean up old backups periodically
find ~ -name "*.backup.*" -mtime +30 -delete
```

## Troubleshooting

### Configuration Not Loading
1. Check for syntax errors: `zsh -n ~/.zshrc`
2. Verify file permissions: `ls -la ~/.zshrc`
3. Check symbolic links: `ls -la ~/.dotfiles/`

### Changes Not Persisting
1. Ensure files are properly linked: `ls -la ~/.zshrc`
2. Check if you're editing the right file (symlink vs actual file)
3. Restart shell or source configuration: `source ~/.zshrc`

### Merge Conflicts
When pulling updates that conflict with your changes:
```bash
# Stash local changes
git stash

# Pull updates
git pull

# Apply your changes back
git stash pop

# Resolve conflicts manually, then commit
```