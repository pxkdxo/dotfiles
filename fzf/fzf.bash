# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/pat/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/pat/.local/share/fzf/bin"
fi

# Auto-completion
# ---------------
# [[ $- == *i* ]] && source "/Users/pat/.local/share/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/Users/pat/.local/share/fzf/shell/key-bindings.bash"
