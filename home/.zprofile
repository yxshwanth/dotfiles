
# Setting PATH for Python 3.13
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:${PATH}"
export PATH

for b in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
export PATH="$HOME/.local/bin:$PATH"
