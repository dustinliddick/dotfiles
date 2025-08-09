# Troubleshooting

## Common Issues

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

You may need to log out and back in for the change to take effect.

### Symlink Issues
If symbolic links aren't created properly, you can create them manually:

```bash
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
# ... repeat for other config files
```

### Oh My Zsh Installation Issues
If Oh My Zsh fails to install automatically, install it manually:

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Plugin Installation Issues
If Zsh plugins aren't working, ensure they're installed in the correct directory:

```bash
# Check if custom plugins directory exists
ls ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/

# If plugins are missing, reinstall them
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Backup Recovery
If you need to restore your original configuration:

```bash
# List available backups
ls -la ~/.dotfiles_backup_*

# Restore from a specific backup (replace TIMESTAMP)
cp ~/.dotfiles_backup_TIMESTAMP/* ~/
```

### Git Configuration Issues
If git commands aren't working as expected, verify your git configuration:

```bash
git config --list --global
```

Make sure your name and email are set:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```