# Setup fzf
# ---------

# if [[ ! "$PATH" == *${HOME}/.local/share/fzf/bin* ]]; then
#   PATH="${PATH:+${PATH}:}${HOME}/.local/share/fzf/bin"
# fi

if command -v fzf > /dev/null; then
  source <(fzf --zsh)
fi
