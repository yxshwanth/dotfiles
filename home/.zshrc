# brew shellenv and ~/.local/bin come from ~/.zprofile; plugins, compinit and history from extras.zsh
typeset -U path

export PATH="/opt/homebrew/opt/python@3.10/bin:/opt/homebrew/opt/postgresql@15/bin:$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)

# nvm.sh costs ~300ms per shell: put the default node on PATH now, load nvm on the first `nvm` call
export NVM_DIR="$HOME/.nvm"
if [[ -r $NVM_DIR/alias/default ]]; then
  _node_bins=( $NVM_DIR/versions/node/v${$(<$NVM_DIR/alias/default)#v}*/bin(Nn) )
  (( $#_node_bins )) && path=( $_node_bins[-1] $path )
  unset _node_bins
fi
nvm() { unfunction nvm; source "$NVM_DIR/nvm.sh"; source "$NVM_DIR/bash_completion"; nvm "$@"; }

[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"

# runs compinit, so completions that need compdef go after it
[ -f ~/.config/zsh/extras.zsh ] && source ~/.config/zsh/extras.zsh

[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

eval "$(starship init zsh)"

path=($path)  # re-assign so typeset -U drops the duplicate PATH entries added above
