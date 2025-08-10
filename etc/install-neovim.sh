#!/usr/bin/env bash
# Neovim installation and validation script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Required Neovim version
REQUIRED_VERSION="0.10.0"

# Function to compare versions
version_compare() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Check if Neovim is installed and get version
check_neovim() {
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim is not installed"
        return 1
    fi
    
    local current_version
    current_version=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    
    print_status "Current Neovim version: $current_version"
    print_status "Required version: $REQUIRED_VERSION"
    
    if version_compare "$current_version" "$REQUIRED_VERSION"; then
        print_success "Neovim version is compatible"
        return 0
    else
        print_warning "Neovim version is outdated (requires >= $REQUIRED_VERSION)"
        return 1
    fi
}

# Install Neovim based on OS
install_neovim() {
    local os_type=$(uname -s)
    
    case "$os_type" in
        "Darwin")
            if command -v brew &> /dev/null; then
                print_status "Installing Neovim via Homebrew..."
                brew install neovim
            else
                print_error "Homebrew not found. Please install Homebrew first."
                print_status "Visit: https://brew.sh"
                exit 1
            fi
            ;;
        "Linux")
            if command -v apt-get &> /dev/null; then
                print_status "Installing Neovim via apt..."
                sudo apt-get update
                sudo apt-get install -y neovim
            elif command -v pacman &> /dev/null; then
                print_status "Installing Neovim via pacman..."
                sudo pacman -S neovim
            elif command -v dnf &> /dev/null; then
                print_status "Installing Neovim via dnf..."
                sudo dnf install -y neovim
            else
                print_warning "Package manager not detected. Attempting AppImage installation..."
                install_neovim_appimage
            fi
            ;;
        *)
            print_error "Unsupported operating system: $os_type"
            exit 1
            ;;
    esac
}

# Install Neovim AppImage for Linux
install_neovim_appimage() {
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"
    
    print_status "Downloading Neovim AppImage..."
    curl -Lo "$install_dir/nvim" https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod +x "$install_dir/nvim"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_status "Adding $install_dir to PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    print_success "Neovim AppImage installed to $install_dir/nvim"
}

# Install Python support for Neovim
install_python_support() {
    print_status "Installing Python support for Neovim..."
    
    # Install pynvim for Python integration
    if command -v pip3 &> /dev/null; then
        pip3 install --user pynvim
    elif command -v pip &> /dev/null; then
        pip install --user pynvim
    else
        print_warning "pip not found. Neovim Python support may not work properly."
    fi
}

# Install Node.js support for Neovim
install_node_support() {
    print_status "Installing Node.js support for Neovim..."
    
    if command -v npm &> /dev/null; then
        npm install -g neovim
    else
        print_warning "npm not found. Neovim Node.js support may not work properly."
    fi
}

# Main installation function
main() {
    print_status "Checking Neovim installation..."
    
    if check_neovim; then
        print_success "Neovim is properly installed and up to date"
    else
        read -p "Would you like to install/update Neovim? [Y/n]: " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$|^$ ]]; then
            install_neovim
            
            # Verify installation
            if check_neovim; then
                print_success "Neovim successfully installed/updated"
            else
                print_error "Neovim installation failed"
                exit 1
            fi
        else
            print_warning "Neovim installation skipped"
            exit 1
        fi
    fi
    
    # Install language support
    read -p "Install Python support for Neovim? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$|^$ ]]; then
        install_python_support
    fi
    
    read -p "Install Node.js support for Neovim? [Y/n]: " -n 1 -r  
    echo
    if [[ $REPLY =~ ^[Yy]$|^$ ]]; then
        install_node_support
    fi
    
    print_success "Neovim setup complete!"
    print_status "You can now run 'nvim' to start Neovim"
}

# Show help
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --check        Only check current installation"
    echo "  --install      Force installation"
    echo ""
    echo "This script will:"
    echo "  1. Check if Neovim is installed and up to date"
    echo "  2. Install/update Neovim if needed"
    echo "  3. Install Python and Node.js support"
}

# Handle command line arguments
case "${1:-}" in
    "-h"|"--help")
        usage
        ;;
    "--check")
        check_neovim
        ;;
    "--install")
        install_neovim
        install_python_support
        install_node_support
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        usage
        exit 1
        ;;
esac