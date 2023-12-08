# Setup fzf
# ---------
if [[ ! "$PATH" == */home/pat/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/pat/.local/share/fzf/bin"
fi

# Auto-completion
# ---------------
# source "/home/pat/.local/share/fzf/shell/completion.bash"

# Key bindings
# ------------
source "/home/pat/.local/share/fzf/shell/key-bindings.bash"
