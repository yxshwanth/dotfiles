# dotfiles

macOS terminal setup: WezTerm, zsh + Starship, tmux, Neovim, and `ox`, one command that switches the color theme across all of them.

## Install

```sh
git clone https://github.com/yxshwanth/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is safe to re-run. It:

1. installs everything in `Brewfile` (needs [Homebrew](https://brew.sh))
2. symlinks every file under `home/` to the same path under `~`; a different file already there is kept as `<name>.pre-dotfiles`
3. clones fzf-tab and tpm, installs yazi flavors
4. renders the current theme with `ox theme`

Then open tmux and press `Ctrl+a` `I` once to install the tmux plugins. Neovim installs its plugins on first launch.

## Editing

The files in `~` are symlinks into this repo, so edit them in place and commit here. To add a new file, put it under `home/` at its path relative to `~` and re-run `install.sh`.

## ox

| command | does |
|---|---|
| `ox theme [name]` | switch theme everywhere: catppuccin, everforest, gruvbox, nord, rose-pine, tokyo-night |
| `ox update` | brew, mise, Neovim plugins, tmux plugins, yazi packages |
| `ox install` | pick a language (mise), database (docker) or tool |
| `ox keys` | searchable cheatsheet of every keybinding (also `Ctrl+a ?` in tmux) |

Themes live in `home/.config/ox/themes/*.sh`, and the per-app templates in `home/.config/ox/templates/`. `ox theme` writes the rendered files to `~/.config/ox/current/`, which is not tracked. It also edits the palette block in `starship.toml`, plus `btop.conf` and `yazi/theme.toml`, so switching themes shows up as a diff here.

## Layout

```
home/.zshrc .zprofile .zshenv      shell; extras.zsh holds history, completion, fzf, aliases
home/.config/wezterm/              translucent window, Ctrl+a leader (tmux off by default: use_tmux)
home/.config/tmux/                 Ctrl+a prefix, popups, cockpit status bar, resurrect/continuum
home/.config/nvim/                 single-file config, lazy.nvim
home/.config/starship.toml         two-line prompt
home/.local/bin/ox, dev            theme switcher; tmux project layout (nvim + claude + shell)
```
