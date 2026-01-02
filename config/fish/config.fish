source (/usr/bin/starship init fish --print-full-init | psub)

alias c='clear'
alias v='nvim'

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
