# Setup fzf
# ---------
if [[ ! "$PATH" == */home/pat/.local/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/pat/.local/opt/fzf/bin"
fi

source <(fzf --zsh)
