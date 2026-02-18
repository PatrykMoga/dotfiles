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
│   └── .scripts/   # Utility scripts
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

**Flexoki Reference**: https://stephango.com/flexoki

Base colors (Dark):
| Name | Hex |
|------|-----|
| black | #100F0F |
| bg | #1C1B1A |
| bg-2 | #282726 |
| ui | #343331 |
| ui-2 | #403E3C |
| ui-3 | #575653 |
| tx-3 | #6F6E69 |
| tx-2 | #878580 |
| tx | #B7B5AC |

Accent colors (Dark, 400):
| Color | Hex |
|-------|-----|
| Red | #D14D41 |
| Orange | #DA702C |
| Yellow | #D0A215 |
| Green | #879A39 |
| Cyan | #3AA99F |
| Blue | #4385BE |
| Purple | #8B7EC8 |
| Magenta | #CE5D97 |

### Claude Integration

`.claude/` is a git submodule containing Claude Code settings, skills, and agents. Shell aliases in `.profile` use Claude for git operations:
- `gc` → Claude commit skill
- `gcp` → Claude commit-push skill
- `gpr` → Claude pull-request skill
- `gr` → Claude release skill
- `an` → Astro project starter (React, Tailwind, sitemap, view transitions)

### Git Workflow

Two-branch model: `main` (default, feature accumulation) and `production` (prod deploys).

- **Features**: `feat/*` → PR to `main` → accumulate → `/release` merges to `production`
- **Hotfixes**: `fix/*` from `production` → PR with `--base production` → merge back to `main`
- **Releases**: `/release` from main calculates semver bump, merges to production, tags, pushes

### Tmux Key Bindings (prefix = \`)

- `E` - Prompt enhancer (clipboard → claude → replace input)
- `o` - Session picker (sessionx)
- `f` - Floating pane (floax)
- `g` - Lazygit popup
- `K` - Keyboard clean (30s blocker)
- `p` - Pomodoro timer
- `N` - Random project name
- `r` - Reload config

### Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `keyboard-clean.swift` | Blocks keyboard for 30s cleaning | `kc` alias. ESC+Enter to exit early. Requires Accessibility permission on first run. |
| `random-name.sh` | Generate random project names | Used by tmux binding |
| `astro-starter.sh` | Scaffold Astro with React, Tailwind, sitemap, view transitions | `an my-project`. Injects ClientRouter post-create. |

## Plan History

| Description | Plan File | Status | Date |
|---|---|---|---|
| Restructure Astro skill with modular references and expanded coverage | N/A (approved in chat) | done | 2026-02-11 |
| Update React skill with 6 additions and create React Email skill | N/A (approved in chat) | done | 2026-02-11 |
| Create /audit skill for instruction quality evaluation | N/A (approved in chat) | done | 2026-02-11 |
| Tmux prompt enhancer that adds validation, test steps, and done conditions | N/A (approved in chat) | done | 2026-02-12 |
| Replace clipboard-based prompt-enhance with signal file + nvim vim-mode integration | N/A (approved in chat) | done | 2026-02-12 |
| Fix semantic theme token gaps: dark mode guidance, bg-white, state tokens, single-example anchoring | N/A (approved in chat) | done | 2026-02-18 |
| Update git workflow: main + production branches, /release skill | N/A (approved in chat) | done | 2026-02-18 |

## Working with This Repo

- After adding/moving files in `home/`, re-stow to update symlinks
- Test config changes by sourcing files directly (e.g., `source ~/.zshrc`)
- Tmux plugins: `prefix + I` to install, `prefix + U` to update
- Neovim plugins managed by lazy.nvim, auto-syncs on startup
