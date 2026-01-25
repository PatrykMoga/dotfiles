# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal macOS dotfiles repository managed with GNU Stow. All dotfiles live in `home/` subdirectory and get symlinked to `~`.

## Commands

```bash
# Install/update symlinks (from repo root)
stow -d . -t ~ home

# Preview changes without applying
stow -n -d . -t ~ --verbose home

# Remove symlinks
stow -D -d . -t ~ home

# Re-stow (useful after moving files)
stow -R -d . -t ~ home
```

## Architecture

### Stow Structure

```
dotfiles/
├── home/           # Everything here gets symlinked to ~/
│   ├── .config/    # XDG config directory
│   ├── .zshrc      # Zsh initialization
│   ├── .profile    # Shell aliases and environment
│   └── scripts/    # Utility scripts
└── .stow-local-ignore  # Patterns excluded from symlinking
```

### Key Configurations

| Tool | Location | Notes |
|------|----------|-------|
| Zsh | `.zshrc`, `.profile` | nvm, zoxide, fzf, starship, auto-tmux |
| Tmux | `.config/tmux/tmux.conf` | Prefix is backtick (\`), uses tpm for plugins |
| Neovim | `.config/nvim/` | LazyVim-based, plugins in `lua/plugins/` |
| Starship | `.config/starship.toml` | Minimal left prompt, info on right |
| Yazi | `.config/yazi/` | File manager with Flexoki Dark theme |
| Ghostty | `.config/ghostty/config` | Primary terminal |
| Alacritty | `.config/alacritty/` | Alternative terminal |
| SketchyBar | `.config/sketchybar/` | macOS menu bar |

### Theme

Flexoki Dark is used consistently across tmux, neovim, ghostty, yazi, and terminal emulators.

### Claude Integration

`.claude/` is a git submodule containing Claude Code settings, skills, and agents. Shell aliases in `.profile` use Claude for git operations:
- `gc` → Claude commit skill
- `gcp` → Claude commit-push skill
- `gpr` → Claude pull-request skill

### Tmux Key Bindings (prefix = \`)

- `o` - Session picker (sessionx)
- `f` - Floating pane (floax)
- `g` - Lazygit popup
- `p` - Pomodoro timer
- `N` - Random project name
- `r` - Reload config

## Working with This Repo

- After adding/moving files in `home/`, re-stow to update symlinks
- Test config changes by sourcing files directly (e.g., `source ~/.zshrc`)
- Tmux plugins: `prefix + I` to install, `prefix + U` to update
- Neovim plugins managed by lazy.nvim, auto-syncs on startup
