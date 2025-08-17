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

# Do not load from dangerous directories.
ZSH_DISABLE_COMPFIX="true"

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
  clipboard-keybindings
  command-not-found
  ctags
  dircolors
  docker
  extract
  fancy-ctrl-z
  fast-syntax-highlighting
  firewalld
  fzf
  gh
  git
  git-prompt
  globalias-rev
  golang
  gpg-agent
  history-substring-search
  iterm2
  keybindings
  kubectl
  kubernetes
  mkcd
  mkmv
  mvcd
  nmap
  npm
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
  vagrant
  venv
  virtualenv
  z
  zsh-autosuggestions
  zsh-completions
  zsh-interactive-cd
  zsh-kitty
  zshaliases
  zshoptions
  zshparam
  zstyle-completion
)

source "$ZSH/oh-my-zsh.sh"

# User configuration

# Configure environment
#
if command -v nvim > /dev/null; then
  export MANPAGER="${MANPAGER:-nvim '+Man!'}"
  export PAGER="${PAGER:-nvim '+Man!' '+set ft=' '+syntax on' -}"
fi
if command -v vim > /dev/null; then
  export MANPAGER="${MANPAGER:-vim -M +MANPAGER -}"
fi
if command -v bat > /dev/null; then
  export BAT_PAGER="${BAT_PAGER:-less ${LESS:--FgiMqRX-2}}"
  export BAT_STYLE="${BAT_STYLE:-grid,header,numbers}"
  export BAT_THEME="${BAT_THEME:-Sublime Snazzy}"
fi

# Configure FZF
#
if (( ${+TMUX} )); then
  export FZF_TMUX=1
  export FZF_TMUX_HEIGHT="${FZF_TMUX_HEIGHT:-45%}"
fi

# Enable fzf-tab completion
export FZF_COMPLETION_TRIGGER=''
bindkey '^P' zic-completion
bindkey '^I' "${fzf_default_completion:-expand-or-complete}"

export FZF_DEFAULT_COMMAND='rg --files-with-matches --smart-case --hidden --follow'
export FZF_ALT_C_COMMAND='fd --hidden --follow --ignore-case --max-depth=1 --strip-cwd-prefix=always --type=directory'
export FZF_CTRL_R_COMMAND="${FZF_CTRL_R_COMMAND:-}"
export FZF_CTRL_T_COMMAND='fd --hidden --follow --ignore-case --max-depth=1 --strip-cwd-prefix=always'

export FZF_DEFAULT_OPTS_FILE="${FZF_DEFAULT_OPTS_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzfrc}"

typeset -Tx FZF_ALT_C_OPTS fzf_alt_c_opts " "
fzf_alt_c_opts=(
  "${fzf_default_opts[@]}"
  --walker=dir,follow
  --smart-case
  --cycle
  --no-sort
  --reverse
  --select-1
  --exit-0
  --scheme=path
  --info=hidden
  --layout=reverse
  --bind=ctrl-r:toggle-sort
  --bind=ctrl-o:"'"'execute-silent(printf %s {2..} | pbcopy)'"'"
  --bind=ctrl-x:"'"'execute-silent(open {2..})+abort'"'"
)

typeset -Tx FZF_CTRL_R_OPTS fzf_ctrl_r_opts " "
fzf_ctrl_r_opts=(
  "${fzf_default_opts[@]}"
  --smart-case
  --cycle
  --sort
  --filepath-word
  --scheme=history
  --info=hidden
  --layout=reverse-list
  --bind=ctrl-r:toggle-sort
  --bind=ctrl-o:"'"'execute-silent(printf %s {2..} | pbcopy)'"'"
  --bind=ctrl-x:"'"'execute-silent(env - {2..})'"'"
)

typeset -Tx FZF_CTRL_T_OPTS fzf_ctrl_t_opts " "
fzf_ctrl_t_opts=(
  "${fzf_default_opts[@]}"
  --multi
  --cycle
  --no-sort
  --multi
  --select-1
  --exit-0
  --scheme=path
  --info=hidden
  --layout=reverse
  --bind=ctrl-r:toggle-sort
  --bind=ctrl-o:"'"'execute-silent(printf %s {2..} | pbcopy)'"'"
  --bind=ctrl-x:"'"'execute-silent(open -- {2..})+abort'"'"
)

# Set fast=completion
#
#fast-theme "${FAST_THEME_NAME:-default}"

# start a tmux session
# if [[ -n ${DISPLAY} && -z ${TMUX} ]] && command -v tmux > /dev/null
# then
#   exec tmux new-session -t ${USER:-$(id -un)} \; new-window
# fi

# vi:et:ft=zsh:sts=2:sw=2:ts=8:tw=0
