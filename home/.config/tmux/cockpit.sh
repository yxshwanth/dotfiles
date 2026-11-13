#!/bin/sh
# Right side of the tmux bar: git branch, Kubernetes context (red on prod), CPU.
# Called by tmux every 5 seconds with the active pane's folder.
dir="${1:-$PWD}"
. "$HOME/.config/ox/current/colors.sh"
pill() { printf '#[fg=%s,bg=default]#[bg=%s,fg=%s,bold] %s #[fg=%s,bg=default,nobold] ' "$1" "$1" "$BG" "$2" "$1"; }

branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$branch" ] && pill "$GREEN" " $branch"

kcfg="${KUBECONFIG:-$HOME/.kube/config}"; kcfg="${kcfg%%:*}"
ctx=$(awk '/^current-context:/ { print $2; exit }' "$kcfg" 2>/dev/null | tr -d '"')
if [ -n "$ctx" ]; then
  case "$ctx" in
    *prod*|*prd*|*production*) pill "$RED" "⎈ $ctx" ;;
    *) pill "$ACCENT2" "⎈ $ctx" ;;
  esac
fi

if [ "$(uname)" = Darwin ]; then n=$(sysctl -n hw.ncpu); else n=$(nproc 2>/dev/null || echo 1); fi
cpu=$(ps -A -o %cpu= | awk -v n="$n" '{ s += $1 } END { printf "%d", s / n }')
pill "$FG2" " $cpu%"
