#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚀 Setting up dotfiles from $DOTFILES_DIR"

# Create backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "📁 Created backup directory: $BACKUP_DIR"
fi

# Function to backup and symlink files
backup_and_link() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file if it exists and is not a symlink
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        echo "📦 Backing up existing $target"
        cp "$target" "$BACKUP_DIR/"
    fi
    
    # Remove existing symlink or file
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm "$target"
    fi
    
    # Create new symlink
    ln -s "$source" "$target"
    echo "🔗 Linked $source -> $target"
}

# Install Homebrew if on macOS and not already installed
if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages from Brewfile if it exists
if [[ "$OSTYPE" == "darwin"* ]] && [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "📦 Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Symlink configuration files
echo "🔗 Creating symlinks..."

# Shell configurations
[ -f "$DOTFILES_DIR/.zshrc" ] && backup_and_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.bashrc" ] && backup_and_link "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
[ -f "$DOTFILES_DIR/.bash_profile" ] && backup_and_link "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"

# Git configurations
[ -f "$DOTFILES_DIR/.gitconfig" ] && backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
[ -f "$DOTFILES_DIR/.gitignore_global" ] && backup_and_link "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

# Editor configurations
[ -f "$DOTFILES_DIR/.vimrc" ] && backup_and_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
[ -f "$DOTFILES_DIR/.tmux.conf" ] && backup_and_link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# SSH configuration
[ -f "$DOTFILES_DIR/.ssh/config" ] && backup_and_link "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"

# Make sure .ssh directory has correct permissions
if [ -d "$HOME/.ssh" ]; then
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
fi

echo "✅ Dotfiles installation complete!"
echo "🗂️  Backup of original files (if any) stored in: $BACKUP_DIR"
echo ""
echo "💡 You may need to restart your terminal or run 'source ~/.zshrc' to apply changes."