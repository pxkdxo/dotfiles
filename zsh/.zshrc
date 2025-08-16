# zshrc: zsh initialization script for interactive shells
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# If this is not an interactive shell, abort.
case $- in
  (*i*) ;;
    (*) return ;;
esac

# # Use manjaro zsh config
# if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
#   source /usr/share/zsh/manjaro-zsh-config
# fi

# # Use manjaro zsh prompt
# if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#   source /usr/share/zsh/manjaro-zsh-prompt
# fi

# Path to the ohmyzsh installation.
export ZSH="${XDG_CONFIG_HOME:-${HOME}/.config}/ohmyzsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="p5kd5o"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
if (( ${+TIME_STYLE} )); then
  HIST_STAMPS="${TIME_STYLE#"${TIME_STYLE%%[^+]*}"}"
else
  HIST_STAMPS='%a %b %d %R %Y'
fi

# Find fzf and set FZF_BASE
if [[ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf" ]]; then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif [[ -d "${HOME}/.local/opt/fzf" ]]; then
  export FZF_BASE="${HOME}/.local/opt/fzf"
elif [[ -d '/usr/local/share/fzf' ]]; then
  export FZF_BASE='/usr/local/share/fzf'
elif [[ -d '/usr/share/fzf' ]]; then
  export FZF_BASE='/usr/share/fzf'
else
  unset -v FZF_BASE
fi

# Temporary fix for git prompts
zstyle ':omz:alpha:lib:git' async-prompt no

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  #kind
  #macos
  #minikube
  #zsh-navigation-tools
  #zsh-syntax-highlighting
  #vi-mode
  1password
  aws
  cdls
  command-not-found
  ctags
  dircolors
  docker
  extract
  fancy-ctrl-z
  firewalld
  fzf
  gh
  git
  git-prompt
  golang
  gpg-agent
  history-substring-search
  iterm2
  kubectl
  kubernetes
  mkcd
  mkmv
  mvcd
  nmap
  npm
  pass
  pip
  pylint
  python
  rsync
  rust
  shrink-path
  sudo
  systemd
  terraform
  tmux
  urltools
  uv
  venv
  z
  zshaliases
  zshoptions
  zshparam
  keybindings
  clipboard-keybindings
  globalias-rev
  fast-syntax-highlighting
  zsh-interactive-cd
  zsh-autosuggestions
  zsh-completions
)

source "$ZSH/oh-my-zsh.sh"

# User configuration

# Configure environment
#
if command -v nvim > /dev/null; then
  export MANPAGER="${MANPAGER:-nvim '+Man!'}"
fi
if command -v vim > /dev/null; then
  export MANPAGER="${MANPAGER:-vim -M +MANPAGER -}"
fi


# Load completions
#
autoload -U -z compinit
compinit -i -d "${ZSH_COMPDUMP:-${ZDOTDIR:-${HOME}}/.zcompdump}"


# Configure FZF
#
if (( ${+TMUX} )); then
  export FZF_TMUX=1
  export FZF_TMUX_HEIGHT="${FZF_TMUX_HEIGHT:-45%}"
else
  unset -v FZF_TMUX
fi

export FZF_COMPLETION_TRIGGER=''
bindkey '^]' zic-completion
bindkey '^I' "${fzf_default_completion:-expand-or-complete}"

typeset -Tx FZF_DEFAULT_OPTS fzf_default_opts " "
fzf_default_opts=(
  '--bind=''ctrl-b:page-up'''
  '--bind=''ctrl-f:page-down'''
  '--bind=''ctrl-j:replace-query+print-query'''
  '--bind=''ctrl-k:kill-line'''
  '--bind=''ctrl-o:execute-silent(printf %s {} | xclip -selection clipboard)'''
  '--bind=''alt-space:toggle-preview'''
  '--bind=''alt-/:jump-accept'''
  '--bind=''insert:replace-query'''
  '--color=''dark'''
  '--color=''header:1,info:3,pointer:5,prompt:5,border:5,fg:4,fg+:6,hl:6,hl+:5'''
  '--prompt=''? '''
  '--border=sharp'
  '--info=hidden'
  '--layout=reverse'
  '--jump-labels=''qwertyuiop'''
)

typeset -Tx FZF_ALT_C_OPTS fzf_alt_c_opts " "
fzf_alt_c_opts=(
  "${fzf_default_opts[@]}"
  '--bind=''ctrl-r:toggle-sort'''
  '--bind=''ctrl-x:execute-silent%rifle -- {}%+abort'''
  '--bind=''alt-e:execute-silent%tmux new-window vim -- {}%+abort'''
  '--bind=''alt-x:execute-silent%tmux new-window ranger --selectfile={}%+abort'''
  '--filepath-word'
  '--no-cycle'
  '--no-sort'
  '--layout=reverse-list'
#  '--preview-window=top:42%'
#  '--preview=''tree -CFlv --dirsfirst -- {} | rg --color=always --no-column --no-heading --no-line-number --passthru -- {q}'''
)

typeset -Tx FZF_CTRL_R_OPTS fzf_ctrl_r_opts " "
fzf_ctrl_r_opts=(
  "${fzf_default_opts[@]}"
  '--bind=''ctrl-r:toggle-sort'''
  '--bind=''ctrl-o:execute-silent(printf %s {2..} | xclip -selection clipboard)'''
  '--bind=''alt-x:execute-silent%tmux new-window zsh -c ''"$@"'' {}%+abort'''
  '--filepath-word'
  '--cycle'
  '--sort'
  '--layout=reverse-list'
)

typeset -Tx FZF_CTRL_T_OPTS fzf_ctrl_t_opts " "
fzf_ctrl_t_opts=(
  "${fzf_default_opts[@]}"
  '--bind=''ctrl-r:toggle-sort'''
  '--bind=''ctrl-x:execute-silent%rifle -- {}%+abort'''
  '--bind=''alt-e:execute-silent%tmux new-window vim -- {}%+abort'''
  '--bind=''alt-x:execute-silent%tmux new-window ranger --selectfile={}%+abort'''
  '--filepath-word'
  '--no-cycle'
  '--no-sort'
  '--layout=reverse-list'
)

typeset -Tx FZF_COMPLETION_OPTS fzf_completion_opts " "
fzf_completion_opts=(
  "${fzf_default_opts[@]}"
  '--bind=''tab:down'''
  '--bind=''shift-tab:up'''
  '--layout=reverse-list'
  '--cycle'
  '-1'
)

typeset -Tx FZF_INTERACTIVE_CD_OPTS fzf_interactive_cd_opts " "
fzf_interactive_cd_opts=(
  "${fzf_default_opts[@]}"
  "${fzf_completion_opts[@]}"
  '--bind=''bspace:backward-delete-char/eof'''
  '--bind=''ctrl-h:backward-delete-char/eof'''
  '--filepath-word'
)


# Attach to a tmux session
#if [[ -z ${TMUX} ]] && command -v tmux > /dev/null; then
#  if tmux has-session 2> /dev/null; then
#    tmux_sessions=("${(@f)$(tmux list-sessions -F '#S')}")
#    if test "${#tmux_sessions[@]}" -gt 0; then
#      printf '*> Attaching to tmux session %q\n' "${tmux_session[1]}"
#      sleep 0.5
#      exec tmux new -d -t "${tmux_session[1]}" ";" "new-window" ";" "attach"
#    fi
#  fi
#fi

# vi:et:ft=zsh:sts=2:sw=2:ts=8:tw=0
