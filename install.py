#!/usr/bin/env python3
"""
Dotfiles installation script.

Single entry point: creates symlinks from $HOME into this repo, installs
Homebrew packages from the Brewfile, and bootstraps the machine-local git
identity. Safe to re-run.

    python3 install.py --dry-run    # show the plan, touch nothing
    python3 install.py              # apply
"""

import argparse
import os
import platform
import shutil
import subprocess
import sys
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
    def __init__(self, dry_run=False):
        self.dotfiles_dir = Path(__file__).parent.absolute()
        self.home_dir = Path.home()
        self.backup_dir = self.home_dir / f".dotfiles_backup_{os.getpid()}"
        self.dry_run = dry_run
        self.is_macos = platform.system() == 'Darwin'
        self.is_linux = platform.system() == 'Linux'
        self.backup_dir_created = False

        # target (relative to $HOME) -> source (relative to this repo)
        #
        # Every file the running machine depends on belongs here. A config
        # that lives in the repo but is missing from this map is invisible to
        # a fresh install: zshenv owns $PATH and zpreztorc loads prezto, so
        # omitting them yields a broken shell on a new machine.
        links = {
            # Zsh. zshrc alone is not enough; the whole startup chain matters.
            '.zshrc': 'zsh/.zshrc',
            '.zshenv': 'zsh/zshenv',
            '.zprofile': 'zsh/zprofile',
            '.zlogin': 'zsh/zlogin',
            '.zlogout': 'zsh/zlogout',
            '.zpreztorc': 'zsh/zpreztorc',
            '.zsh': 'zsh',
            '.p10k.zsh': 'zsh/p10k.zsh',

            # Bash, kept for non-interactive and remote shells.
            '.bashrc': 'zsh/.bashrc',
            '.bash_profile': 'zsh/.bash_profile',

            # Git. gitconfig sets excludesfile = ~/.gitignore, so that is the
            # live one; .gitignore_global is vestigial but still linked so an
            # existing checkout is reproduced exactly.
            '.gitconfig': 'git/gitconfig',
            '.gitignore': 'git/gitignore',
            '.gitignore_global': 'git/gitignore',

            # Vim.
            '.vim': 'vim',
            '.vimrc': 'vim/.vimrc',

            # Tmux.
            '.tmux.conf': 'config/tmux/tmux.conf',
            '.tmux': 'config/tmux',

            # XDG config directories.
            '.config/nvim': 'config/nvim',
            '.config/alacritty': 'config/alacritty',
            '.config/bat': 'config/bat',
            '.config/kitty': 'config/kitty',
            '.config/wezterm': 'config/wezterm',
            '.config/pycodestyle': 'python/pycodestyle',
            '.config/ptpython': 'python',

            # Python.
            '.pythonrc.py': 'python/pythonrc.py',
            '.pylintrc': 'python/pylintrc',
            '.condarc': 'python/condarc',

            # Claude commands.
            '.claude/commands': 'claude/commands',

            # Cross-platform misc.
            '.screenrc': 'screenrc',
        }

        # X11/GTK settings are meaningless on macOS; linking them there just
        # litters $HOME.
        if self.is_linux:
            links['.Xmodmap'] = 'Xmodmap'
            links['.gtkrc-2.0'] = 'gtkrc-2.0'

        self.tasks = {
            self.home_dir / target: self.dotfiles_dir / source
            for target, source in links.items()
        }

    def create_backup_dir(self):
        """Create backup directory for existing files (lazily, on first use)"""
        if self.backup_dir_created or self.dry_run:
            return True
        try:
            self.backup_dir.mkdir(exist_ok=True)
            self.backup_dir_created = True
            print_info(f"Backup directory created: {self.backup_dir}")
        except Exception as e:
            print_error(f"Failed to create backup directory: {e}")
            return False
        return True

    def backup_file(self, file_path):
        """Backup an existing real file or directory"""
        if not file_path.exists():
            return True
        if not self.create_backup_dir():
            return False
        backup_path = self.backup_dir / file_path.name
        try:
            if file_path.is_dir():
                shutil.copytree(file_path, backup_path, dirs_exist_ok=True)
            else:
                shutil.copy2(file_path, backup_path)
            print_info(f"Backed up: {file_path.name}")
            return True
        except Exception as e:
            print_error(f"Failed to backup {file_path}: {e}")
            return False

    def create_symlink(self, target, source):
        """Create a symbolic link, replacing whatever is currently at target"""
        try:
            if not source.exists():
                print_warning(f"Source does not exist, skipping: {source}")
                return True

            rel = target.relative_to(self.home_dir)

            # A symlink is checked BEFORE existence. os.path.exists() follows
            # links, so a dir symlink pointing elsewhere looks like a real
            # directory and symlink_to() would write *through* it, creating a
            # nested link inside the wrong tree (this is what produced
            # tmux/tmux and vim/vim in the old dotfiles checkout).
            if target.is_symlink():
                current = os.readlink(target)
                if current == str(source):
                    print_info(f"Already linked: ~/{rel}")
                    return True
                if self.dry_run:
                    print_warning(f"WOULD RELINK ~/{rel} (currently -> {current})")
                    return True
                target.unlink()
                print_warning(f"Replaced stale link: ~/{rel} (was -> {current})")
            elif target.exists():
                if self.dry_run:
                    print_warning(f"WOULD BACK UP AND REPLACE real path ~/{rel}")
                    return True
                if not self.backup_file(target):
                    return False
                if target.is_dir():
                    shutil.rmtree(target)
                else:
                    target.unlink()
            else:
                if self.dry_run:
                    print_success(f"WOULD LINK ~/{rel} -> {source}")
                    return True

            target.parent.mkdir(parents=True, exist_ok=True)
            target.symlink_to(source)
            print_success(f"Linked: ~/{rel}")
            return True

        except Exception as e:
            print_error(f"Failed to create symlink {target}: {e}")
            return False

    def create_symlinks(self):
        """Create all configured symlinks"""
        print_colored("📁 Creating Symbolic Links", Colors.BLUE)
        print_colored("─" * 80, Colors.BLUE)

        success_count = 0
        for target, source in sorted(self.tasks.items()):
            if self.create_symlink(target, source):
                success_count += 1

        print()
        print_success(f"{success_count}/{len(self.tasks)} symlinks OK")
        return success_count == len(self.tasks)

    def install_packages(self):
        """Install Homebrew and Brewfile packages on macOS"""
        print()
        print_colored("🍺 Packages", Colors.BLUE)
        print_colored("─" * 80, Colors.BLUE)

        if not self.is_macos:
            print_info("Not macOS, skipping Homebrew")
            return True

        brewfile = self.dotfiles_dir / 'Brewfile'
        if not brewfile.exists():
            print_warning("No Brewfile found, skipping")
            return True

        if not shutil.which('brew'):
            print_warning("Homebrew not installed. Install it first:")
            print('   /bin/bash -c "$(curl -fsSL '
                  'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
            return True

        if self.dry_run:
            print_info(f"WOULD RUN: brew bundle --file={brewfile}")
            return True

        print_info("Running brew bundle (this can take a while)...")
        try:
            subprocess.run(['brew', 'bundle', f'--file={brewfile}'], check=True)
            print_success("Brewfile packages installed")
            return True
        except subprocess.CalledProcessError as e:
            print_error(f"brew bundle failed (exit {e.returncode})")
            return False

    def bootstrap_git_identity(self):
        """Create ~/.gitconfig.secret from the template if absent"""
        print()
        print_colored("🔑 Git Identity", Colors.BLUE)
        print_colored("─" * 80, Colors.BLUE)

        secret = self.home_dir / '.gitconfig.secret'
        template = self.dotfiles_dir / '.gitconfig.secret.template'

        if secret.exists():
            print_info("~/.gitconfig.secret already exists, leaving it alone")
            return True
        if not template.exists():
            print_warning("No .gitconfig.secret.template found, skipping")
            return True
        if self.dry_run:
            print_info(f"WOULD CREATE ~/.gitconfig.secret from {template.name}")
            return True

        try:
            shutil.copy2(template, secret)
            secret.chmod(0o600)
            print_success("Created ~/.gitconfig.secret from template")
            print_warning("Edit it and set your real email before committing anything")
            return True
        except Exception as e:
            print_error(f"Failed to create ~/.gitconfig.secret: {e}")
            return False

    def set_permissions(self):
        """Set proper permissions for SSH files"""
        print()
        print_colored("🔒 Setting Permissions", Colors.BLUE)
        print_colored("─" * 80, Colors.BLUE)

        ssh_dir = self.home_dir / '.ssh'
        if not ssh_dir.exists():
            print_info("No SSH directory found")
            return True
        if self.dry_run:
            print_info("WOULD CHMOD ~/.ssh to 700 (and config to 600)")
            return True

        try:
            ssh_dir.chmod(0o700)
            ssh_config = ssh_dir / 'config'
            if ssh_config.exists():
                ssh_config.chmod(0o600)
            print_success("Set SSH permissions")
        except Exception as e:
            print_error(f"Failed to set SSH permissions: {e}")
            return False
        return True

    def install(self):
        """Main installation function"""
        print_header()
        if self.dry_run:
            print_colored("DRY RUN — nothing will be modified", Colors.YELLOW)
            print()
        print_info(f"Source directory: {self.dotfiles_dir}")
        print_info(f"Platform: {platform.system()}")
        print()

        ok = self.create_symlinks()
        if not ok:
            print_error("Some symlinks failed to create")

        self.install_packages()
        self.bootstrap_git_identity()
        self.set_permissions()

        print()
        print_colored("🎯 Installation Summary", Colors.PURPLE)
        print_colored("─" * 80, Colors.PURPLE)
        if self.dry_run:
            print_info("Dry run complete. Re-run without --dry-run to apply.")
            return True

        print_success("Installation completed!")
        print()
        print_colored("Next Steps:", Colors.YELLOW)
        print("   1. Set your git identity in ~/.gitconfig.secret")
        print("   2. Restart your terminal or run: exec zsh")
        print("   3. Configure Powerlevel10k prompt: p10k configure")
        print("   4. Install Tmux Plugin Manager: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm")
        print("   5. In tmux, press prefix + I to install plugins")
        print("   6. Open Neovim and run :Lazy to install plugins")
        print("   7. Install Claude CLI: https://docs.anthropic.com/en/docs/claude-code/quickstart")
        print()

        return True


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Install dotfiles by symlinking them into $HOME.")
    parser.add_argument('--dry-run', action='store_true',
                        help="show what would change without modifying anything")
    args = parser.parse_args()

    installer = DotfilesInstaller(dry_run=args.dry_run)

    try:
        return 0 if installer.install() else 1
    except KeyboardInterrupt:
        print_warning("\nInstallation interrupted by user")
        return 1
    except Exception as e:
        print_error(f"Installation failed: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
