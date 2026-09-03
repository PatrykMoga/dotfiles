# Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `keyboard-clean.swift` | Blocks keyboard for 30s cleaning | `kc` alias. ESC+Enter to exit early. Requires Accessibility permission on first run. |
| `random-name.sh` | Generate random project names | Used by tmux binding |
| `caffeine.sh` | Toggle `caffeinate -disu` + `pmset disablesleep`; watches the lid and fires `pmset displaysleepnow` on close, so the normal "lock immediately" rule runs (with sleep disabled macOS emits no sleep or display-sleep event of its own). Locks the screen; does not log out — the session and its processes keep running | `prefix + C`. State is read from `pmset SleepDisabled`, surfaced as `@caffeine` in the left status bar. `--selftest` checks the password reader. |
| `claude-usage.sh` | Claude plan usage (5h / 7d / per-model) for the tmux status bar, from the OAuth usage endpoint with a 60s cache | Rendered by tmux `status-right`, shared across panes. `--selftest` checks thresholds and countdowns. |
| `astro-init.sh` | Scaffold Astro (Svelte, Tailwind, sitemap, view transitions) + git init + private GitHub repo + main/production branches | `ai my-project`. Injects ClientRouter post-create. Requires `gh` authenticated. |
| `xcode-init.sh` | Initialize fresh Xcode project: iOS 26 / Swift 6 / iPhone-only build settings, .gitignore, git init, private GitHub repo, main + production branches | `xi` alias. Run from project root after creating .xcodeproj in Xcode. Requires `gh` authenticated. |
