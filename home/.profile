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
alias ai='~/.scripts/astro-init.sh'
alias xi='~/.scripts/xcode-init.sh'
alias gpf='git push --force-with-lease'
alias grl='git reset HEAD~1'
# gc/gcp: fast model-free-orchestration commit. git-ai-commit.sh makes a single
# one-shot `claude -p` call for the message (~10s vs the old ~30s multi-turn
# skill) and handles submodules privacy-safely. Stage first, then commit.
alias gc='~/.scripts/git-ai-commit.sh'
alias gcp='~/.scripts/git-ai-commit.sh --push'
# gpr/gr still use their skills (unchanged). CLAUDE_GIT_NESTED=1 stops the Stop
# auto-checkpoint hook from looping when these headless claude -p sessions end.
alias gpr='CLAUDE_GIT_NESTED=1 claude -p "/pull-request" --allowedTools "Bash(git status*)" "Bash(git log*)" "Bash(git branch*)" "Bash(gh pr*)"'
alias gr='CLAUDE_GIT_NESTED=1 claude -p "/release" --allowedTools "Bash(git log*)" "Bash(git tag*)" "Bash(git branch*)" "Bash(git checkout*)" "Bash(git merge*)" "Bash(git push*)" "Bash(git status*)" "Bash(git diff*)" "Bash(git add*)" "Bash(git commit*)"'
alias rl='~/.claude/hooks/ralph-loop.sh'

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/patrykmoga/.lmstudio/bin"
