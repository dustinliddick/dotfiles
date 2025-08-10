# ~/.zshrc - Zsh configuration (inspired by wookayin/dotfiles)
# Personal configuration for enhanced zsh experience

# Performance optimization: Enable loader for faster startup
if [[ -v ZSH_PROFILE_LOG ]] && command -v zmodload > /dev/null 2>&1; then
  zmodload zsh/datetime
  setopt PROMPT_SUBST
  PS4='+$EPOCHREALTIME %N:%i> '
  exec 3>&2 2>${ZSH_PROFILE_LOG:-/tmp/zsh-profile.log}
  setopt XTRACE
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Initialize completion system before plugins
autoload -Uz compinit
compinit

# Antidote plugin manager setup
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

# Load generated plugins (static loading for performance)  
source /Users/dustinliddick/personal_projects/dotfiles/zsh/.zsh_plugins.zsh

# Terminal settings
export COLORTERM="truecolor"
export CLICOLOR=1

# Host color for prompt (wookayin style)
HOST_COLOR="${HOST_COLOR:-6}"  # cyan

# Dynamic tab color for SSH (iTerm2)
if [[ -n "$SSH_CONNECTION" ]] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  echo -ne "\033]6;1;bg;red;brightness;64\a"
  echo -ne "\033]6;1;bg;green;brightness;128\a" 
  echo -ne "\033]6;1;bg;blue;brightness;255\a"
fi

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Path configuration
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Go configuration
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Python configuration
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Lazy loading for performance-critical tools
# Node Version Manager (nvm) - Lazy loading
export NVM_DIR="$HOME/.nvm"
_lazy_load_nvm() {
  unset -f node npm npx nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
node() { _lazy_load_nvm; node "$@"; }
npm() { _lazy_load_nvm; npm "$@"; }
npx() { _lazy_load_nvm; npx "$@"; }
nvm() { _lazy_load_nvm; nvm "$@"; }

# wookayin-style aliases and functions

# Basic aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'  
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'
alias h='history'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enhanced tools
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi
alias preview='fzf --preview "bat --color=always --style=numbers --line-range=:300 {}"'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Development aliases
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server 8000'
alias json='pbpaste | jq "." | pbcopy'
alias reload='source ~/.zshrc'

# Network and system
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulanp'

# wookayin-style advanced functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and kill process by name (enhanced with fzf)
function fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m --header="[kill:process]" | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m --header="[kill:process]" | awk '{print $2}')
    fi
    
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Enhanced git log with fzf integration  
function glog() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --header="[git:log] CTRL-S:toggle-sort, ENTER:show commit" \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
                FZF-EOF"
}

# Enhanced cd with fzf (recursive directory finder)
function cdf() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git . ${1:-.} | fzf --header="[cd:dir]") &&
    cd "$dir"
}

# Search and edit files with fzf + editor
function fe() {
    local files
    IFS=$'\n' files=($(fd --type f --hidden --follow --exclude .git . ${1:-.} | fzf -m --header="[edit:files]"))
    [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# Process search with fzf (enhanced)
function fps() {
    local pid
    pid=$(ps aux | fzf --header="[process:search]" --header-lines=1 | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo "PID: $pid"
    fi
}

# Enhanced file extraction
function extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# wookayin-style ZSH options
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD              # pushd automatically when cd  
setopt PUSHD_IGNORE_DUPS       # ignore duplicate entries in pushd
setopt CORRECT                 # command spelling correction
setopt HIST_VERIFY             # verify history expansion
setopt EXTENDED_GLOB           # enable extended globbing
setopt NO_CASE_GLOB            # case insensitive globbing
setopt NUMERIC_GLOB_SORT       # sort numeric glob results
setopt APPEND_HISTORY          # append to history file
setopt INC_APPEND_HISTORY      # append incrementally
setopt SHARE_HISTORY           # share history between sessions
setopt HIST_IGNORE_DUPS        # ignore duplicate commands
setopt HIST_REDUCE_BLANKS      # remove unnecessary blanks

# Enhanced completion system
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# FZF configuration (wookayin style)
if command -v fzf >/dev/null 2>&1; then
  # Use fd for better file finding
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  
  # Enhanced FZF options with better colors
  export FZF_DEFAULT_OPTS='
    --height 40% --layout=reverse --border --margin=1 --padding=1
    --color=fg:#c0c0c0,bg:#1e1e1e,hl:#569cd6
    --color=fg+:#ffffff,bg+:#2d2d30,hl+:#4fc1ff
    --color=info:#ce9178,prompt:#d19a66,pointer:#e06c75
    --color=marker:#98c379,spinner:#56b6c2,header:#61afef'
    
  # FZF key bindings and completion
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# iTerm2 shell integration (macOS)
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Terminfo compatibility
if [[ "$COLORTERM" == "gnome-terminal" || "$COLORTERM" == "xfce4-terminal" ]]; then
  export TERM=xterm-256color
fi

# Load Powerlevel10k configuration
[[ ! -f /Users/dustinliddick/personal_projects/dotfiles/zsh/p10k.zsh ]] || source /Users/dustinliddick/personal_projects/dotfiles/zsh/p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load local customizations
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

# Profiling end
if [[ -v ZSH_PROFILE_LOG ]]; then
  unsetopt XTRACE
  exec 2>&3 3>&-
fi
