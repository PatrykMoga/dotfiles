. "$HOME/.cargo/env"

# Aliases
alias sp='source ~/.profile'
alias vim='nvim'
alias v='nvim'
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
alias tc='tuicr'
alias c='claude'
alias cc='claude --continue'
alias cr='claude --resume'
alias cf='claude --model fable'
alias co='claude --model opus'
alias cs='claude --model sonnet'
alias ch='claude --model haiku'
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
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias gpf='git push --force-with-lease'
alias grl='git reset HEAD~1'
# gc/gcp: fast model-free-orchestration commit. git-ai-commit.sh makes a single
# one-shot `claude -p` call for the message (~10s vs the old ~30s multi-turn
# skill) and handles submodules privacy-safely. Stage first, then commit.
alias gc='~/.scripts/git-ai-commit.sh'
alias gcp='~/.scripts/git-ai-commit.sh --push'
# gpr still uses its skill. CLAUDE_GIT_NESTED=1 stops the Stop
# auto-checkpoint hook from looping when these headless claude -p sessions end.
# Releases: run /release from an interactive claude session (the gr print-mode
# alias could not service gh/AskUserQuestion and silently failed).
alias gpr='CLAUDE_GIT_NESTED=1 claude -p "/pull-request" --allowedTools "Bash(git status*)" "Bash(git log*)" "Bash(git branch*)" "Bash(gh pr*)"'

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/patrykmoga/.lmstudio/bin"
