# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/patrick.deyoreo/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/patrick.deyoreo/.local/share/fzf/bin"
fi

source <(fzf --zsh)
