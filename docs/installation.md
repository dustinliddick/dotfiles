# Installation

## Manual Installation

```bash
$ git clone --recursive https://github.com/dustin-liddick/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles && python install.py
```

The installation script will clone the repository into `~/.dotfiles` and create symbolic links (e.g., `~/.vimrc`) for you.
If target files already exist (e.g. `~/.vim`, `~/.vimrc`), you will need to manually resolve the conflict (delete the old one or just ignore). See [Troubleshooting](troubleshooting.md) for details.

## Local Software Installation (Linux)

On Linux, you can [install some common softwares locally](../etc/linux-locals.sh) (into `$HOME/.local/bin`) *without sudo*:

```bash
$ dotfiles install neovim         # -> ~/.local/bin/nvim
$ dotfiles install ripgrep        # -> ~/.local/bin/rg
```

## Personal Configuration Setup

After installation, you'll need to set up your personal information:

### Git Configuration
Copy the template and customize it:
```bash
cp ~/.dotfiles/.gitconfig.secret.template ~/.gitconfig.secret
# Edit ~/.gitconfig.secret with your name, email, and GitHub username
```

### SSH Keys
Make sure your SSH keys are set up for GitHub:
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
# Add the public key to your GitHub account
```