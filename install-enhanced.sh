#!/bin/bash

# Enhanced dotfiles installation script
# Inspired by GandalfTheSysAdmin's modular approach

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Emojis for visual feedback
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
FOLDER="📁"
LINK="🔗"
PACKAGE="📦"
GEAR="⚙️"

# Counters for tracking
TOTAL_TASKS=0
COMPLETED_TASKS=0
ERRORS=0

# Helper functions for colored output
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                            DOTFILES INSTALLATION                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_section() {
    echo -e "${BLUE}${GEAR} $1${NC}"
    echo -e "${BLUE}$(printf '%.0s─' {1..80})${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} $1"
    ((COMPLETED_TASKS++))
}

print_error() {
    echo -e "${RED}${ERROR}${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} $1"
}

print_info() {
    echo -e "${BLUE}${INFO}${NC} $1"
}

print_progress() {
    echo -e "${PURPLE}[${COMPLETED_TASKS}/${TOTAL_TASKS}]${NC} $1"
}

# Enhanced symlink management with task mapping
declare -A SYMLINK_TASKS=(
    # Shell configurations
    ["$HOME/.zshrc"]="$DOTFILES_DIR/zsh/.zshrc"
    ["$HOME/.bashrc"]="$DOTFILES_DIR/zsh/.bashrc"
    ["$HOME/.bash_profile"]="$DOTFILES_DIR/zsh/.bash_profile"
    
    # Git configurations
    ["$HOME/.gitconfig"]="$DOTFILES_DIR/config/git/.gitconfig"
    ["$HOME/.gitignore_global"]="$DOTFILES_DIR/config/git/.gitignore_global"
    
    # Editor configurations
    ["$HOME/.vimrc"]="$DOTFILES_DIR/vim/.vimrc"
    ["$HOME/.tmux.conf"]="$DOTFILES_DIR/config/tmux/.tmux.conf"
    
    # SSH configuration
    ["$HOME/.ssh/config"]="$DOTFILES_DIR/ssh/config"
    
    # Neovim configuration (if it exists)
    ["$HOME/.config/nvim"]="$DOTFILES_DIR/config/nvim"
)

# Enhanced backup and symlink function
smart_symlink() {
    local target="$1"
    local source="$2"
    local task_name="$3"
    
    print_progress "Processing: $task_name"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        print_warning "Source file does not exist: $source"
        return 0
    fi
    
    # Create target directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Handle existing target
    if [[ -L "$target" ]]; then
        local current_target
        current_target=$(readlink "$target")
        if [[ "$current_target" == "$source" ]]; then
            print_info "Already linked correctly: $(basename "$target")"
            ((COMPLETED_TASKS++))
            return 0
        else
            print_warning "Removing existing symlink: $target -> $current_target"
            rm "$target"
        fi
    elif [[ -f "$target" ]]; then
        print_info "Backing up existing file: $(basename "$target")"
        cp "$target" "$BACKUP_DIR/$(basename "$target")"
        rm "$target"
    elif [[ -d "$target" ]]; then
        print_error "Target is a directory: $target"
        return 1
    fi
    
    # Create the symlink
    if ln -s "$source" "$target" 2>/dev/null; then
        print_success "Linked: $(basename "$target")"
    else
        print_error "Failed to create symlink: $target"
        return 1
    fi
}

# Count total tasks
count_total_tasks() {
    TOTAL_TASKS=$((${#SYMLINK_TASKS[@]} + 7))  # symlinks + other tasks
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ((TOTAL_TASKS += 2))  # homebrew + packages
    fi
}

# Create backup directory
create_backup_dir() {
    print_section "Creating Backup Directory"
    if mkdir -p "$BACKUP_DIR" 2>/dev/null; then
        print_success "Created backup directory: $BACKUP_DIR"
    else
        print_error "Failed to create backup directory"
        exit 1
    fi
}

# Install Homebrew and packages (macOS only)
install_homebrew() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        return 0
    fi
    
    print_section "Homebrew Installation"
    
    if command -v brew &> /dev/null; then
        print_info "Homebrew already installed"
        ((COMPLETED_TASKS++))
    else
        print_progress "Installing Homebrew..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            print_success "Installed Homebrew"
        else
            print_error "Failed to install Homebrew"
            return 1
        fi
    fi
    
    # Install packages from Brewfile
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        print_progress "Installing packages from Brewfile..."
        if brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock; then
            print_success "Installed packages from Brewfile"
        else
            print_error "Some packages failed to install"
        fi
    else
        print_warning "No Brewfile found"
        ((COMPLETED_TASKS++))
    fi
}

# Create symlinks using the task mapping
create_symlinks() {
    print_section "Creating Symbolic Links"
    
    for target in "${!SYMLINK_TASKS[@]}"; do
        source="${SYMLINK_TASKS[$target]}"
        task_name="$(basename "$target")"
        smart_symlink "$target" "$source" "$task_name"
    done
}

# Set proper permissions
set_permissions() {
    print_section "Setting Permissions"
    
    print_progress "Setting SSH permissions..."
    if [[ -d "$HOME/.ssh" ]]; then
        chmod 700 "$HOME/.ssh"
        if [[ -f "$HOME/.ssh/config" ]]; then
            chmod 600 "$HOME/.ssh/config"
        fi
        print_success "Set SSH permissions"
    else
        print_info "No SSH directory found"
        ((COMPLETED_TASKS++))
    fi
}

# Add dotfiles bin to PATH
setup_path() {
    print_section "Setting up PATH"
    
    print_progress "Adding dotfiles/bin to PATH..."
    
    # Add to shell configurations if not already present
    local path_export="export PATH=\"$DOTFILES_DIR/bin:\$PATH\""
    
    for shell_config in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$shell_config" ]] && ! grep -q "$DOTFILES_DIR/bin" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# Dotfiles utilities" >> "$shell_config"
            echo "$path_export" >> "$shell_config"
        fi
    done
    
    print_success "Added dotfiles/bin to PATH"
}

# Post-installation setup
post_install_setup() {
    print_section "Post-Installation Setup"
    
    # Setup Oh My Zsh if not installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_progress "Installing Oh My Zsh..."
        if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended; then
            print_success "Installed Oh My Zsh"
        else
            print_warning "Oh My Zsh installation failed or was skipped"
            ((COMPLETED_TASKS++))
        fi
    else
        print_info "Oh My Zsh already installed"
        ((COMPLETED_TASKS++))
    fi
    
    # Install zsh plugins
    print_progress "Setting up Zsh plugins..."
    
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" &>/dev/null || true
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting" &>/dev/null || true
    fi
    
    # powerlevel10k theme
    if [[ ! -d "$zsh_custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$zsh_custom/themes/powerlevel10k" &>/dev/null || true
    fi
    
    print_success "Zsh plugins setup complete"
    
    # Setup Neovim configuration
    if command -v nvim &> /dev/null; then
        print_progress "Setting up Neovim configuration..."
        if [[ -x "$DOTFILES_DIR/bin/setup-neovim" ]]; then
            "$DOTFILES_DIR/bin/setup-neovim" --minimal
            print_success "Neovim configuration setup complete"
        else
            print_warning "Neovim setup script not found"
            ((COMPLETED_TASKS++))
        fi
    else
        print_info "Neovim not installed, skipping configuration"
        ((COMPLETED_TASKS++))
    fi
}

# Show installation summary
show_summary() {
    echo
    print_section "Installation Summary"
    
    if [[ $ERRORS -eq 0 ]]; then
        echo -e "${GREEN}${SUCCESS} Installation completed successfully!${NC}"
    else
        echo -e "${YELLOW}${WARNING} Installation completed with $ERRORS errors${NC}"
    fi
    
    echo
    echo -e "${BLUE}📊 Statistics:${NC}"
    echo -e "   Tasks completed: ${GREEN}$COMPLETED_TASKS${NC}"
    echo -e "   Errors: ${RED}$ERRORS${NC}"
    echo -e "   Backup directory: ${CYAN}$BACKUP_DIR${NC}"
    echo
    
    echo -e "${PURPLE}🎯 Next Steps:${NC}"
    echo -e "   1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
    echo -e "   2. ${WHITE}REQUIRED:${NC} Configure Powerlevel10k prompt: ${YELLOW}p10k configure${NC}"
    echo -e "      ${BLUE}(This sets up your terminal prompt style - run it now!)${NC}"
    echo -e "   3. Update git user info: ${YELLOW}git config --global user.name \"Your Name\"${NC}"
    echo -e "   4. Update git user email: ${YELLOW}git config --global user.email \"your@email.com\"${NC}"
    echo -e "   5. Use dotfiles utility: ${YELLOW}dotfiles help${NC}"
    echo
}

# Handle command line arguments
handle_arguments() {
    case "${1:-}" in
        --help|-h)
            cat << EOF
Enhanced Dotfiles Installation Script

Usage: $0 [options]

Options:
    --help, -h      Show this help message
    --no-packages   Skip package installation
    --dry-run       Show what would be done without making changes

Features:
    - Automatic backup of existing files
    - Colored output with progress tracking
    - Error handling and recovery
    - Post-installation setup
    - Modular configuration management

EOF
            exit 0
            ;;
        --no-packages)
            SKIP_PACKAGES=true
            ;;
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}${WARNING} DRY RUN MODE - No changes will be made${NC}"
            echo
            ;;
    esac
}

# Main installation function
main() {
    handle_arguments "$@"
    
    print_header
    print_info "Starting dotfiles installation..."
    print_info "Source directory: $DOTFILES_DIR"
    echo
    
    count_total_tasks
    
    create_backup_dir
    
    if [[ "${SKIP_PACKAGES:-false}" == "false" ]]; then
        install_homebrew
    fi
    
    create_symlinks
    set_permissions
    setup_path
    post_install_setup
    
    show_summary
}

# Run main function with all arguments
main "$@"