#!/usr/bin/env bash
# macOS system configuration script
# Configures system preferences, Dock, Finder, and other macOS settings

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

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is only for macOS"
        exit 1
    fi
}

# System Preferences
configure_system() {
    print_status "Configuring system preferences..."
    
    # Set key repeat rate (fast)
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Always show scrollbars
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
    
    # Disable smart quotes and dashes (useful for coding)
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    
    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    
    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    
    print_success "System preferences configured"
}

# Dock configuration
configure_dock() {
    print_status "Configuring Dock..."
    
    # Make Dock auto-hide instantly
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # Set dock to bottom and make it smaller
    defaults write com.apple.dock orientation -string "bottom"
    defaults write com.apple.dock tilesize -int 36
    
    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false
    
    # Show indicators for open applications
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Restart Dock
    killall Dock
    
    print_success "Dock configured"
}

# Finder configuration
configure_finder() {
    print_status "Configuring Finder..."
    
    # Show status bar and path bar
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Disable warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Default view style (list view)
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # Search current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    
    # Restart Finder
    killall Finder
    
    print_success "Finder configured"
}

# Terminal configuration
configure_terminal() {
    print_status "Configuring Terminal..."
    
    # Use UTF-8 only in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4
    
    print_success "Terminal configured"
}

# Screenshot configuration  
configure_screenshots() {
    print_status "Configuring screenshots..."
    
    # Save screenshots to ~/Pictures/Screenshots
    mkdir -p "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
    
    # Save screenshots in PNG format
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    
    print_success "Screenshots configured"
}

# Trackpad and mouse configuration
configure_input() {
    print_status "Configuring trackpad and mouse..."
    
    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    
    # Enable three finger drag
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    
    print_success "Input devices configured"
}

# Security and privacy
configure_security() {
    print_status "Configuring security settings..."
    
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    print_success "Security settings configured"
}

# Main configuration function
configure_all() {
    print_status "Starting macOS configuration..."
    echo ""
    
    configure_system
    configure_dock
    configure_finder
    configure_terminal
    configure_screenshots
    configure_input
    configure_security
    
    echo ""
    print_success "macOS configuration complete!"
    print_warning "Some changes require a restart to take effect"
}

# Script usage
usage() {
    echo "Usage: $0 [function]"
    echo ""
    echo "Available functions:"
    echo "  system      - Configure system preferences"
    echo "  dock        - Configure Dock settings"
    echo "  finder      - Configure Finder settings"
    echo "  terminal    - Configure Terminal settings"
    echo "  screenshots - Configure screenshot settings"
    echo "  input       - Configure trackpad and mouse"
    echo "  security    - Configure security settings"
    echo "  all         - Run all configurations (default)"
    echo ""
    echo "Example:"
    echo "  $0 dock     # Configure only Dock settings"
    echo "  $0 all      # Configure everything"
}

# Main script execution
main() {
    check_macos
    
    case "${1:-all}" in
        "system")
            configure_system
            ;;
        "dock")
            configure_dock
            ;;
        "finder")
            configure_finder
            ;;
        "terminal")
            configure_terminal
            ;;
        "screenshots")
            configure_screenshots
            ;;
        "input")
            configure_input
            ;;
        "security")
            configure_security
            ;;
        "all")
            configure_all
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        *)
            print_error "Unknown function: $1"
            echo ""
            usage
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi