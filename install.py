#!/usr/bin/env python3
"""
Dotfiles installation script
Based on GandalfTheSysAdmin's approach
"""

import os
import sys
import shutil
from pathlib import Path


class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'  # No Color


def print_colored(message, color):
    print(f"{color}{message}{Colors.NC}")


def print_success(message):
    print_colored(f"✅ {message}", Colors.GREEN)


def print_error(message):
    print_colored(f"❌ {message}", Colors.RED)


def print_warning(message):
    print_colored(f"⚠️  {message}", Colors.YELLOW)


def print_info(message):
    print_colored(f"ℹ️  {message}", Colors.BLUE)


def print_header():
    print_colored("╔══════════════════════════════════════════════════════════════════════════════╗", Colors.CYAN)
    print_colored("║                            DOTFILES INSTALLATION                              ║", Colors.CYAN)
    print_colored("╚══════════════════════════════════════════════════════════════════════════════╝", Colors.CYAN)
    print()


class DotfilesInstaller:
    def __init__(self):
        self.dotfiles_dir = Path(__file__).parent.absolute()
        self.home_dir = Path.home()
        self.backup_dir = self.home_dir / f".dotfiles_backup_{os.getpid()}"
        
        # Define symlink tasks
        self.tasks = {
            # Shell configurations
            self.home_dir / '.zshrc': self.dotfiles_dir / 'zsh' / '.zshrc',
            
            # Git configurations  
            self.home_dir / '.gitconfig': self.dotfiles_dir / 'git' / 'gitconfig',
            self.home_dir / '.gitignore_global': self.dotfiles_dir / 'git' / 'gitignore',
            
            # Claude commands
            self.home_dir / '.claude' / 'commands': self.dotfiles_dir / 'claude' / 'commands',
            
            # Tmux configuration
            self.home_dir / '.tmux.conf': self.dotfiles_dir / 'config' / 'tmux' / 'tmux.conf',
            
            # Neovim configuration
            self.home_dir / '.config' / 'nvim': self.dotfiles_dir / 'config' / 'nvim',
            
            # Alacritty configuration
            self.home_dir / '.config' / 'alacritty': self.dotfiles_dir / 'config' / 'alacritty',
            
            # Python configurations
            self.home_dir / '.pythonrc.py': self.dotfiles_dir / 'python' / 'pythonrc.py',
            self.home_dir / '.pylintrc': self.dotfiles_dir / 'python' / 'pylintrc',
            self.home_dir / '.condarc': self.dotfiles_dir / 'python' / 'condarc',
            self.home_dir / '.config' / 'pycodestyle': self.dotfiles_dir / 'python' / 'pycodestyle',
            self.home_dir / '.config' / 'ptpython': self.dotfiles_dir / 'python',
            
            # Powerlevel10k configuration
            self.home_dir / '.p10k.zsh': self.dotfiles_dir / 'zsh' / 'p10k.zsh',
        }
    
    def create_backup_dir(self):
        """Create backup directory for existing files"""
        print_info("Creating backup directory...")
        try:
            self.backup_dir.mkdir(exist_ok=True)
            print_success(f"Backup directory created: {self.backup_dir}")
        except Exception as e:
            print_error(f"Failed to create backup directory: {e}")
            return False
        return True
    
    def backup_file(self, file_path):
        """Backup an existing file"""
        if file_path.exists():
            backup_path = self.backup_dir / file_path.name
            try:
                if file_path.is_file():
                    shutil.copy2(file_path, backup_path)
                elif file_path.is_dir():
                    shutil.copytree(file_path, backup_path, dirs_exist_ok=True)
                print_info(f"Backed up: {file_path.name}")
                return True
            except Exception as e:
                print_error(f"Failed to backup {file_path}: {e}")
                return False
        return True
    
    def create_symlink(self, target, source):
        """Create a symbolic link"""
        try:
            # Check if source exists
            if not source.exists():
                print_warning(f"Source does not exist, skipping: {source}")
                return True
            
            # Create parent directory if needed
            target.parent.mkdir(parents=True, exist_ok=True)
            
            # Handle existing target
            if target.is_symlink():
                if target.readlink() == source:
                    print_info(f"Already linked correctly: {target.name}")
                    return True
                else:
                    print_warning(f"Removing existing symlink: {target}")
                    target.unlink()
            elif target.exists():
                if not self.backup_file(target):
                    return False
                if target.is_file():
                    target.unlink()
                elif target.is_dir():
                    shutil.rmtree(target)
            
            # Create the symlink
            target.symlink_to(source)
            print_success(f"Linked: {target.name}")
            return True
            
        except Exception as e:
            print_error(f"Failed to create symlink {target}: {e}")
            return False
    
    def create_symlinks(self):
        """Create all configured symlinks"""
        print_colored("📁 Creating Symbolic Links", Colors.BLUE)
        print_colored("─" * 80, Colors.BLUE)
        
        success_count = 0
        for target, source in self.tasks.items():
            if self.create_symlink(target, source):
                success_count += 1
        
        print()
        print_success(f"Created {success_count}/{len(self.tasks)} symlinks")
        return success_count == len(self.tasks)
    
    def set_permissions(self):
        """Set proper permissions for SSH files"""
        print_colored("🔒 Setting Permissions", Colors.BLUE)
        print_colored("─" * 80, Colors.BLUE)
        
        ssh_dir = self.home_dir / '.ssh'
        if ssh_dir.exists():
            try:
                ssh_dir.chmod(0o700)
                ssh_config = ssh_dir / 'config'
                if ssh_config.exists():
                    ssh_config.chmod(0o600)
                print_success("Set SSH permissions")
            except Exception as e:
                print_error(f"Failed to set SSH permissions: {e}")
                return False
        else:
            print_info("No SSH directory found")
        
        return True
    
    def install(self):
        """Main installation function"""
        print_header()
        print_info("Starting dotfiles installation...")
        print_info(f"Source directory: {self.dotfiles_dir}")
        print()
        
        # Create backup directory
        if not self.create_backup_dir():
            return False
        
        # Create symlinks
        if not self.create_symlinks():
            print_error("Some symlinks failed to create")
        
        # Set permissions
        self.set_permissions()
        
        print()
        print_colored("🎯 Installation Summary", Colors.PURPLE)
        print_colored("─" * 80, Colors.PURPLE)
        print_success("Installation completed!")
        print()
        print_colored("Next Steps:", Colors.YELLOW)
        print("   1. Install dependencies: brew install antidote fd fzf bat ripgrep")
        print("   2. Install Claude CLI: https://docs.anthropic.com/en/docs/claude-code/quickstart")
        print("   3. Restart your terminal or run: source ~/.zshrc")
        print("   4. Configure Powerlevel10k prompt: p10k configure")
        print("   5. Install Tmux Plugin Manager: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm")
        print("   6. In tmux, press prefix + I to install plugins")
        print("   7. Update git user info: git config --global user.name \"Your Name\"")
        print("   8. Update git user email: git config --global user.email \"your@email.com\"")
        print("   9. Open Neovim and run :Lazy to install plugins")
        print("  10. Install language servers: npm install -g typescript-language-server")
        print()
        
        return True


def main():
    """Main entry point"""
    installer = DotfilesInstaller()
    
    if len(sys.argv) > 1 and sys.argv[1] in ['--help', '-h']:
        print("Dotfiles Installation Script")
        print()
        print("Usage: python install.py")
        print()
        print("This script will:")
        print("  - Create backups of existing dotfiles")
        print("  - Create symlinks to dotfiles in this repository")
        print("  - Set appropriate permissions")
        return 0
    
    try:
        success = installer.install()
        return 0 if success else 1
    except KeyboardInterrupt:
        print_warning("\nInstallation interrupted by user")
        return 1
    except Exception as e:
        print_error(f"Installation failed: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())