. "$HOME/.cargo/env"

# Aliases
alias vim='nvim'
alias v='nvim'
alias lg='lazygit'
alias c='claude'
alias ls='ls --color=auto'
alias b='brew'
alias bout='brew outdated'
alias bug='brew upgrade'
alias l='ls -la'
alias t='tmux'

alias dev="cd ~/Developer/"
alias dot="cd ~/Developer/dotfiles/"

# Git
alias gpf='git push --force-with-lease'
alias grl='git reset HEAD~1'
alias gc='claude -p "/git:commit" --allowedTools "Bash(git status*)" "Bash(git diff*)" "Bash(git log*)" "Bash(git add*)" "Bash(git commit*)" "Bash(git submodule*)" "Bash(git -C*)"'
alias gcp='claude -p "/git:commit-push" --allowedTools "Bash(git status*)" "Bash(git diff*)" "Bash(git log*)" "Bash(git add*)" "Bash(git commit*)" "Bash(git push*)" "Bash(git submodule*)" "Bash(git -C*)"'
alias gpr='claude -p "/git:pull-request" --allowedTools "Bash(git status*)" "Bash(git log*)" "Bash(git branch*)" "Bash(gh pr*)"'

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/patrykmoga/.lmstudio/bin"
