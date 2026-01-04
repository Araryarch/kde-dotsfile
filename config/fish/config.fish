function fish_greeting
    pokemon-colorscripts -r --no-title
end

source (/usr/bin/starship init fish --print-full-init | psub)

alias c='clear'
alias v='nvim'
alias brd='bun dev'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias brb='bun run build'
alias prd='pnpm run dev'
alias prb='pnpm run build'
alias ls='eza --icons --git'
alias ll='eza -la --icons --git'
alias tree='eza --tree --icons'
alias ngefix='git add . && git commit -m "fix: fix" && git push'

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
