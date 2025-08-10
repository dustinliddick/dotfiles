# My dotfiles

These are the config files that make my development environment feel like home. I spend most of my time working with Python, Java, and AWS stuff, so everything's tuned for that workflow.

## What I use

Here's what's in my daily driver setup:

- **Shell**: Zsh with all the aliases I actually use (no bloat, promise)
- **Editor**: Neovim as my main editor, with Vim as backup when things get weird
- **Terminal**: Alacritty because I live in the terminal
- **Multiplexer**: Tmux for juggling projects without losing my mind
- **Git**: Aliases that save me from typing the same commands 100 times a day
- **AWS**: CLI shortcuts because nobody remembers those command flags
- **Packages**: Brewfile with the tools I can't live without

## Getting started

Clone this repo and run the installer:

```bash
git clone https://github.com/dustinliddick/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.py
```

After that, run `p10k configure` to set up your prompt how you like it, then restart your terminal.

## What's in here

```
├── config/
│   ├── git/           # Git config and global gitignore
│   ├── nvim/          # Neovim setup (my main editor)
│   └── tmux/          # Tmux configuration
├── zsh/               # Zsh shell config with useful aliases
├── vim/               # Vim config (backup when nvim acts up)
├── bin/               # Helper scripts I actually use
├── Brewfile           # All the packages I need
└── install.py         # Setup script that won't break your existing stuff
```

## The idea

I built this setup around my day-to-day work:
- **Python stuff**: Virtual env helpers, linting shortcuts, testing aliases
- **Java projects**: Maven/Gradle shortcuts because typing `mvn clean install` gets old
- **AWS work**: CLI aliases for the commands I use most
- **General productivity**: Scripts that save me time and keep my terminal organized
- **Safe setup**: The installer backs up your existing configs instead of nuking them

---

*Feel free to fork and adapt these configs for your own setup! If you find something useful, I'd love to hear about it.*
