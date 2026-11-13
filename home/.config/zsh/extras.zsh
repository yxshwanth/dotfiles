# ~/.config/zsh/extras.zsh
# Loaded from ~/.zshrc. Better commands, smarter completion, Catppuccin colors.

_brew="${HOMEBREW_PREFIX:-/opt/homebrew}"
export PATH="$HOME/.local/bin:$PATH"

# source the first file that exists
_load() { for f in "$@"; do [[ -r "$f" ]] && { source "$f"; return 0; }; done; return 1; }

# ---------------- history ----------------
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE

# ---------------- completion ----------------
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit && compinit
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'

# ---------------- fzf (Ctrl+r history, Ctrl+t files, Option+c folders) ----------------
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS=" \
  --height=50% --layout=reverse --border=rounded --info=inline-right \
  --prompt='❯ ' --pointer='▌' --marker='┃'"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=always --color=always {}'"
command -v fzf >/dev/null && source <(fzf --zsh)

# ---------------- fzf-tab (Tab opens a searchable menu) ----------------
if _load "$HOME/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh"; then
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons=always --color=always $realpath'
  [[ -n "$TMUX" ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

# ---------------- zoxide (z <part of folder name>) ----------------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ---------------- bat (colored cat and man pages) ----------------
export BAT_THEME="ansi"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# ---------------- aliases ----------------
if command -v eza >/dev/null; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --git --group-directories-first'
  alias la='eza -la --icons=auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
fi
command -v bat >/dev/null && alias cat='bat --paging=never'
alias lg='lazygit'

# ---------------- yazi: y opens it, and you land in the folder you quit in ----------------
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ---------------- autosuggestions (grey hint, Right arrow accepts) ----------------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
_load "$_brew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
      "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
      "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
      "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ---------------- syntax highlighting (must be last) ----------------
_load "$_brew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
      "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
      "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
      "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


# colors for fzf, autosuggest and syntax highlighting: rendered by `ox theme`
_load "$HOME/.config/ox/current/colors.zsh"

# ---------------- mise (language runtimes), lazygit theme ----------------
command -v mise >/dev/null && eval "$(mise activate zsh)"
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/ox/current/lazygit.yml"

unset _brew

# ---------------- suggestion keys ----------------
# Ctrl+Space accepts the whole grey suggestion (Ctrl+e and Right arrow also work)
# Option+f accepts just the next word
bindkey '^ ' autosuggest-accept
