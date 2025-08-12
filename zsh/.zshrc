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

# Find fzf and add it to the PATH
if [[ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf" ]]; then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif [[ -d '/usr/local/share/fzf' ]]; then
  export FZF_BASE='/usr/local/share/fzf'
elif [[ -d '/usr/share/fzf' ]]; then
  export FZF_BASE='/usr/share/fzf'
else
  unset -v FZF_BASE
fi
if [[ -v FZF_BASE ]]; then
  if [[ :"${PATH}": != *:"${FZF_BASE}/bin":* ]]; then
    export PATH="${PATH:+${PATH}:}${FZF_BASE}/bin"
  fi
fi

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Temporary fix for git prompts
zstyle ':omz:alpha:lib:git' async-prompt no

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  aws
  cdls
  clipboard-keybindings
  command-not-found
  ctags
  dircolors
  docker
  docker-compose
  docker-shortcuts
  extract
  fancy-ctrl-z
  fzf
  git
  globalias-rev
  golang
  gpg-agent
  history-substring-search
  httpie
  jsontools
  keybindings
  #kind
  kubectl
  kubernetes
  #minikube
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
  systemd
  terraform
  themes
  tmux
  urltools
  vagrant
  venv
  virtualenv
  yarn
  z
  zsh-kitty
  zsh-autosuggestions
  zsh-completions
  #zsh-navigation-tools
  zsh-interactive-cd
  zsh-syntax-highlighting
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
if command -v vimpager > /dev/null; then
  export PAGER="${PAGER:-vimpager}"
fi
if command -v bat > /dev/null; then
  export BAT_PAGER="${BAT_PAGER:-less ${LESS--FgiMqRX-2}}"
  export BAT_STYLE="${BAT_STYLE:-grid,header,numbers}"
  export BAT_THEME="${BAT_THEME:-Sublime Snazzy}"
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
bindkey '^ ' fzf-completion
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

# Configure syntax highlighting
#
ZSH_HIGHLIGHT_HIGHLIGHTERS=(
  main
  brackets
  cursor
)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[arg0]='none'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[assign]='none'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green,underline'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=blue'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-6]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command-substitution]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]='none'
ZSH_HIGHLIGHT_STYLES[commandseparator]='bold'
ZSH_HIGHLIGHT_STYLES[comment]='fg=black,bold'
ZSH_HIGHLIGHT_STYLES[cursor]='none'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
#ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='none'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
#ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[line]='none'
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='none'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=''
ZSH_HIGHLIGHT_STYLES[precommand]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[process-substitution]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='none'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=blue'
ZSH_HIGHLIGHT_STYLES[redirection]='none'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[root]='standout'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='none'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
#ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'


# start a tmux session
# if [[ -n ${DISPLAY} && -z ${TMUX} ]] && command -v tmux > /dev/null
# then
#   exec tmux new-session -t ${USER:-$(id -un)} \; new-window
# fi

# vi:et:ft=zsh:sts=2:sw=2:ts=8:tw=0
