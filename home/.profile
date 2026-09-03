. "$HOME/.cargo/env"

# Aliases
alias sp='source ~/.profile'
alias vim='nvim'
alias v='nvim'
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
alias tc='tuicr'
# Claude Code renders 256-color when TMUX is set; this restores truecolor.
export CLAUDE_CODE_TMUX_TRUECOLOR=1

alias c='claude --advisor fable'
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
alias ppk='pkill -f pnpm'
# ppl: dev servers as port -> project dir, then other pnpm tasks (install/build)
ppl() {
  printf '%-6s %-7s %s\n' PORT PID PROJECT
  lsof -a -nP -iTCP -sTCP:LISTEN -c node 2>/dev/null | awk 'NR>1 {n=split($9,a,":"); print a[n], $2}' | sort -un |
    while read -r port pid; do
      printf '%-6s %-7s %s\n' "$port" "$pid" "$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | sed "s|$HOME|~|")"
    done
  echo
  pgrep -fl 'pnpm (run |dev|build|install)|wrangler' | cut -c1-160
}
alias pd='pnpm dev'
# w* = ship it. wu uploads a version without routing traffic to it, wv promotes
# an already-uploaded one (interactive: pick version + %), wd does both at once.
alias wu='pnpm build && pnpm wrangler versions upload'
alias wd='pnpm build && pnpm wrangler deploy'
alias wv='pnpm wrangler versions deploy'
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
