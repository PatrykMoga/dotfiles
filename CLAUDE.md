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

### Theme

Flexoki Dark is used consistently across tmux, neovim, ghostty, yazi, and terminal emulators.

**Flexoki Reference**: https://stephango.com/flexoki

### Claude Integration

`.claude/` is a git submodule containing Claude Code settings, skills, and agents.

Shell aliases live in `.profile`. Releases are the exception — run `/release` from an interactive claude session (no alias; print mode can't service it).

### Git Workflow

Two-branch model: `main` (default, feature accumulation) and `production` (prod deploys).

- **Features**: `feat/*` → PR to `main` → accumulate → `/release` merges to `production`
- **Hotfixes**: `fix/*` from `production` → PR with `--base production` → merge back to `main`
- **Releases**: `/release` from main calculates semver bump, merges to production, tags, pushes

## Working with This Repo

- Superpowers specs/plans and other Claude-config docs go to `home/.claude/docs/superpowers/` (private submodule), never to a top-level `docs/`
- After adding/moving files in `home/`, re-stow to update symlinks
- Test config changes by sourcing files directly (e.g., `source ~/.zshrc`)
- Tmux plugins: `prefix + I` to install, `prefix + U` to update
- Neovim plugins managed by lazy.nvim, auto-syncs on startup
