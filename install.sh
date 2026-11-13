#!/usr/bin/env bash
# ./install.sh   link home/ into ~, install tools and plugins, render the theme. Safe to re-run.
set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"

# ---- tools ----
if command -v brew >/dev/null; then
  brew bundle check --file "$DOT/Brewfile" >/dev/null || brew bundle install --no-upgrade --file "$DOT/Brewfile"
else
  echo "Homebrew not found: install it from https://brew.sh, then re-run" >&2
fi

# ---- links: every file in home/ gets a symlink at the same path under ~ ----
cd "$DOT/home"
find . -type f ! -name .DS_Store | while read -r f; do
  f="${f#./}"; src="$DOT/home/$f"; dst="$HOME/$f"
  [[ -L $dst && $(readlink "$dst") == "$src" ]] && continue
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst || -L $dst ]]; then
    if cmp -s "$dst" "$src"; then rm "$dst"; else mv "$dst" "$dst.pre-dotfiles" && echo "kept old $f as $f.pre-dotfiles"; fi
  fi
  ln -s "$src" "$dst" && echo "linked $f"
done

# ---- plugins (Neovim installs its own on first launch; tmux: press prefix + I once) ----
[[ -d ~/.local/share/zsh/fzf-tab ]] || git clone --depth 1 https://github.com/Aloxaf/fzf-tab ~/.local/share/zsh/fzf-tab
[[ -d ~/.config/tmux/plugins/tpm ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
if command -v ya >/dev/null; then ya pkg install; fi

# ---- theme: renders ~/.config/ox/current for wezterm, tmux, nvim, zsh, lazygit, btop ----
~/.local/bin/ox theme "$(cat ~/.config/ox/theme)"
