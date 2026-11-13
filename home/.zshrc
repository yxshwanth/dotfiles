# brew shellenv and ~/.local/bin come from ~/.zprofile; plugins, compinit and history from extras.zsh
typeset -U path

export PATH="/opt/homebrew/opt/python@3.10/bin:/opt/homebrew/opt/postgresql@15/bin:$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"

# runs compinit, so completions that need compdef go after it
[ -f ~/.config/zsh/extras.zsh ] && source ~/.config/zsh/extras.zsh

[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

eval "$(starship init zsh)"

path=($path)  # re-assign so typeset -U drops the duplicate PATH entries added above
