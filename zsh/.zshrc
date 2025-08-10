# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
    git
    brew
    macos
    node
    npm
    docker
    kubectl
    terraform
    aws
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Export PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Node Version Manager (nvm) - Lazy loading for performance
export NVM_DIR="$HOME/.nvm"

# Lazy load nvm for better shell startup performance
nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}

node() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    node "$@"
}

npm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    npm "$@"
}

npx() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    npx "$@"
}

# Python
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

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
alias glog='git log --oneline --decorate --graph'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias deactivate='deactivate'
alias pyinstall='pip3 install -r requirements.txt'
alias pyfreeze='pip3 freeze > requirements.txt'

# Java aliases
alias mvnci='mvn clean install'
alias mvntest='mvn test'
alias mvnrun='mvn spring-boot:run'
alias gradlew='./gradlew'
alias gw='./gradlew'

# AWS aliases
alias awswhoami='aws sts get-caller-identity'
alias awsprofiles='aws configure list-profiles'
alias ec2='aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name,InstanceType,Tags[?Key=='"'"'Name'"'"'].Value|[0]]" --output table'

# JSON aliases
alias jqp='jq . -C'  # pretty print with colors
alias jsonfmt='python3 -m json.tool'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias drmi='docker rmi'
alias drmf='docker rm -f'

# Additional productivity aliases
alias tree='tree -C'
alias du='du -h'
alias df='df -h'
alias free='top -l 1 -s 0 | head -8'
alias ls='ls -G'
alias ll='ls -lahG'
alias cat='bat --paging=never'
alias preview='fzf --preview "bat --color=always {}"'

# Network aliases
alias myip='curl ifconfig.me'
alias localip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias ports='netstat -tulanp'

# System monitoring
alias cpu='top -o cpu'
alias mem='top -o mem'
alias disk='df -h | grep -E "^(/dev/|Filesystem)"'

# Development shortcuts
alias serve='python3 -m http.server 8000'
alias json='pbpaste | jq "." | pbcopy'
alias reload='source ~/.zshrc'

# Advanced functions from wookayin/dotfiles
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and kill process by name
fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi
    
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Git log with fzf integration
glog() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
                FZF-EOF"
}

# Enhanced cd with fzf
cdf() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
}

# Search and edit files with fzf + vim
fe() {
    local files
    IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Process search with fzf
fps() {
    local pid
    pid=$(ps aux | fzf --header="[process:search]" | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo $pid
    fi
}

# Python project setup
pyproject() {
    mkdir -p "$1" && cd "$1"
    python3 -m venv venv
    source venv/bin/activate
    echo "venv/" > .gitignore
    echo "__pycache__/" >> .gitignore
    echo "*.pyc" >> .gitignore
    echo "# $1" > README.md
    touch requirements.txt
    git init
    echo "Created Python project: $1"
}

# AWS profile switcher
awsprofile() {
    if [ -z "$1" ]; then
        echo "Current profile: ${AWS_PROFILE:-default}"
        echo "Available profiles:"
        aws configure list-profiles
    else
        export AWS_PROFILE="$1"
        echo "Switched to AWS profile: $1"
    fi
}

# JSON validation
jsoncheck() {
    if [ -f "$1" ]; then
        python3 -m json.tool "$1" > /dev/null && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
    else
        echo "$1" | python3 -m json.tool > /dev/null && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
    fi
}

extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Advanced ZSH options for better experience
setopt AUTO_CD              # cd by typing directory name if not a command
setopt AUTO_PUSHD           # pushd automatically when cd
setopt PUSHD_IGNORE_DUPS    # ignore duplicate entries in pushd
setopt CORRECT              # correct command spelling
setopt HIST_VERIFY          # verify history expansion
setopt EXTENDED_GLOB        # enable extended globbing
setopt NO_CASE_GLOB         # case insensitive globbing
setopt NUMERIC_GLOB_SORT    # sort numeric glob results
setopt APPEND_HISTORY       # append to history file
setopt INC_APPEND_HISTORY   # append incrementally
setopt SHARE_HISTORY        # share history between sessions

# Enhanced completion settings
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
  --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
  --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
  --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.dotfiles/zsh/p10k.zsh ]] || source ~/.dotfiles/zsh/p10k.zsh

# Local customizations
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local