. "$HOME/.cargo/env"

# Aliases
alias sp='source ~/.profile'
alias vim='nvim'
alias v='nvim'
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
alias c='claude'
alias cc='claude --continue'
alias cr='claude --resume'
alias ls='ls --color=auto'
alias b='brew'
alias bout='brew outdated'
alias bug='brew upgrade'
alias l='ls -la'
alias t='tmux'
alias sr=''
alias dev="cd ~/Developer/"
alias dot="cd ~/Developer/dotfiles/"
alias kc='~/.scripts/keyboard-clean'
alias pk='pkill -f pnpm'
alias pp='ps aux | grep pnpm'
alias an='pnpm create astro@latest'
alias gpf='git push --force-with-lease'
alias grl='git reset HEAD~1'
alias gc='claude -p "/commit" --allowedTools "Bash(git status*)" "Bash(git diff*)" "Bash(git log*)" "Bash(git add*)" "Bash(git commit*)" "Bash(git submodule*)" "Bash(git -C*)"'
alias gcp='claude -p "/commit --push" --allowedTools "Bash(git status*)" "Bash(git diff*)" "Bash(git log*)" "Bash(git add*)" "Bash(git commit*)" "Bash(git push*)" "Bash(git submodule*)" "Bash(git -C*)"'
alias gpr='claude -p "/pull-request" --allowedTools "Bash(git status*)" "Bash(git log*)" "Bash(git branch*)" "Bash(gh pr*)"'

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/patrykmoga/.lmstudio/bin"
