# Qarvix Zsh Config

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[3~' delete-char

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias v='nvim'
alias q='qarvix-ctl'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'

# Path
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

# Starship prompt
eval "$(starship init zsh)"
