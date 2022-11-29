# Setup fzf
# ---------
if [[ ! "$PATH" == */home/pat/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/pat/.local/share/fzf/bin"
fi

# Auto-completion
# ---------------
# [[ $- == *i* ]] && source "/home/pat/.local/share/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
# source "/home/pat/.local/share/fzf/shell/key-bindings.zsh"
