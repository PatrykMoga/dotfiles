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

`.claude/` is a git submodule containing Claude Code settings, skills, and agents. Shell aliases in `.profile`:
- `gc` / `gcp` → AI commit (+push) via `~/.scripts/git-ai-commit.sh` (single-shot `claude -p` message)
- `gpr` → `/pull-request` skill headless
- Releases → run `/release` from an interactive claude session (no alias; print mode can't service it)
- `ai` → Astro project init (Svelte, Tailwind, sitemap, view transitions) + git + private repo + main/production branches
- `xi` → Xcode project init (iOS 26 / Swift 6 / iPhone-only build settings) + git + private repo + main/production branches

### Git Workflow

Two-branch model: `main` (default, feature accumulation) and `production` (prod deploys).

- **Features**: `feat/*` → PR to `main` → accumulate → `/release` merges to `production`
- **Hotfixes**: `fix/*` from `production` → PR with `--base production` → merge back to `main`
- **Releases**: `/release` from main calculates semver bump, merges to production, tags, pushes

### Tmux Key Bindings (prefix = \`)

- `E` - Prompt menu (Optimize / Blueprint / Socratic)
- `o` - Session picker (sessionx)
- `f` - Floating pane (floax)
- `g` - Lazygit popup
- `K` - Keyboard clean (30s blocker)
- `C` - Caffeine toggle (stay awake with the lid closed; prompts for sudo)
- `p` - Pomodoro timer
- `N` - Random project name
- `r` - Reload config

### Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `keyboard-clean.swift` | Blocks keyboard for 30s cleaning | `kc` alias. ESC+Enter to exit early. Requires Accessibility permission on first run. |
| `random-name.sh` | Generate random project names | Used by tmux binding |
| `caffeine.sh` | Toggle `caffeinate -disu` + `pmset disablesleep`; watches the lid and fires `pmset displaysleepnow` on close, so the normal "lock immediately" rule runs (with sleep disabled macOS emits no sleep or display-sleep event of its own). Locks the screen; does not log out — the session and its processes keep running | `prefix + C`. State is read from `pmset SleepDisabled`, surfaced as `@caffeine` in the left status bar. `--selftest` checks the password reader. |
| `claude-usage.sh` | Claude plan usage (5h / 7d / per-model) for the tmux status bar, from the OAuth usage endpoint with a 60s cache | Rendered by tmux `status-right`, shared across panes. `--selftest` checks thresholds and countdowns. |
| `astro-init.sh` | Scaffold Astro (Svelte, Tailwind, sitemap, view transitions) + git init + private GitHub repo + main/production branches | `ai my-project`. Injects ClientRouter post-create. Requires `gh` authenticated. |
| `xcode-init.sh` | Initialize fresh Xcode project: iOS 26 / Swift 6 / iPhone-only build settings, .gitignore, git init, private GitHub repo, main + production branches | `xi` alias. Run from project root after creating .xcodeproj in Xcode. Requires `gh` authenticated. |

## Working with This Repo

- This repo is public. Superpowers specs/plans and other Claude-config docs go to `home/.claude/docs/superpowers/` (private submodule), never to a top-level `docs/`
- After adding/moving files in `home/`, re-stow to update symlinks
- Test config changes by sourcing files directly (e.g., `source ~/.zshrc`)
- Tmux plugins: `prefix + I` to install, `prefix + U` to update
- Neovim plugins managed by lazy.nvim, auto-syncs on startup

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
