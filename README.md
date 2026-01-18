# dotfiles

Personal macOS configuration files managed with GNU Stow.

## Tools

- **tmux** - Terminal multiplexer with catppuccin theme, floax popups, and sessionx session management
- **neovim** - Primary text editor
- **starship** - Cross-shell prompt
- **yazi** - Terminal file manager
- **ghostty** - GPU-accelerated terminal
- **alacritty** - Alternative terminal emulator
- **zsh** - Shell with zoxide, fzf, and autosuggestions

## Prerequisites

- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)
- [tmux](https://github.com/tmux/tmux) (`brew install tmux`)
- [Neovim](https://neovim.io) (`brew install neovim`)
- [Starship](https://starship.rs) (`brew install starship`)
- [Yazi](https://yazi-rs.github.io) (`brew install yazi`)
- [zoxide](https://github.com/ajeetdsouza/zoxide) (`brew install zoxide`)
- [fzf](https://github.com/junegunn/fzf) (`brew install fzf`)
- [lazygit](https://github.com/jesseduffield/lazygit) (`brew install lazygit`)

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
stow .
```

To preview what stow will do:
```bash
stow -n --verbose .
```

## tmux Keybindings

Prefix is `C-s` (Ctrl+s).

| Key | Action |
|-----|--------|
| `prefix + p` | Toggle floating pane (floax) |
| `prefix + o` | Session picker (sessionx) |
| `prefix + g` | Lazygit popup |
| `prefix + R` | Reload tmux config |

## Shell Features

- Opens tmux automatically on new terminal
- `y` - Launch yazi file manager with directory changing
- `z` - Jump to directories with zoxide
- fzf keybindings for history and file search
