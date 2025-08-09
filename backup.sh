#!/bin/bash

set -e

BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "🗂️  Creating backup of existing dotfiles..."

# Create backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "📁 Created backup directory: $BACKUP_DIR"
fi

# Files to backup
FILES_TO_BACKUP=(
    ".zshrc"
    ".bashrc"
    ".bash_profile"
    ".gitconfig"
    ".gitignore_global"
    ".vimrc"
    ".tmux.conf"
    ".ssh/config"
)

# Function to backup a file
backup_file() {
    local file="$1"
    local source_path="$HOME/$file"
    local backup_path="$BACKUP_DIR/$file"
    
    if [ -f "$source_path" ] && [ ! -L "$source_path" ]; then
        # Create directory structure if needed
        mkdir -p "$(dirname "$backup_path")"
        
        # Copy the file
        cp "$source_path" "$backup_path"
        echo "📦 Backed up: $file"
    elif [ -L "$source_path" ]; then
        echo "⚠️  Skipped $file (already a symlink)"
    else
        echo "ℹ️  Skipped $file (doesn't exist)"
    fi
}

# Backup each file
for file in "${FILES_TO_BACKUP[@]}"; do
    backup_file "$file"
done

# Also backup any existing Oh My Zsh configuration
if [ -f "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ]; then
    cp "$HOME/.p10k.zsh" "$BACKUP_DIR/"
    echo "📦 Backed up: .p10k.zsh"
fi

# Backup SSH keys (but not config, as that's already handled above)
if [ -d "$HOME/.ssh" ]; then
    mkdir -p "$BACKUP_DIR/.ssh"
    
    # Backup SSH keys
    for key_file in "$HOME/.ssh"/*; do
        if [ -f "$key_file" ] && [[ "$key_file" != *"/config" ]] && [[ "$key_file" != *"/known_hosts" ]]; then
            filename=$(basename "$key_file")
            cp "$key_file" "$BACKUP_DIR/.ssh/"
            echo "📦 Backed up SSH file: $filename"
        fi
    done
fi

echo ""
echo "✅ Backup completed successfully!"
echo "🗂️  All files backed up to: $BACKUP_DIR"
echo ""
echo "💡 To restore from backup later, you can copy files back:"
echo "   cp $BACKUP_DIR/.zshrc ~/"
echo "   cp $BACKUP_DIR/.gitconfig ~/"
echo "   # etc..."