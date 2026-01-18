
source $HOME/.profile

export EDITOR=nvim

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/patrykmoga/.lmstudio/bin"

# pnpm
export PNPM_HOME="/Users/patrykmoga/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# yazi shell wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# setup zoxide
eval "$(zoxide init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Auto-start tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    session_count=$(tmux list-sessions 2>/dev/null | wc -l)
    if [ "$session_count" -gt 1 ]; then
        # Multiple sessions exist - show sessionx picker
        tmux new-session -d -s temp_session 2>/dev/null || true
        tmux attach-session -t temp_session \; run-shell "~/.config/tmux/plugins/tmux-sessionx/scripts/sessionx.sh"
    elif [ "$session_count" -eq 1 ]; then
        # One session exists - create new session
        tmux new-session
    else
        # No sessions - create first session
        tmux new-session
    fi
fi
