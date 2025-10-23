# zshrc: zsh initialization script for interactive shells
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# If this is not an interactive shell, abort.
case $- in
  (*i*) ;;
  (*) return ;;
esac

# Path to the ohmyzsh installation.
if test -v ZDOTDIR; then
  ZSH="${ZDOTDIR:-${HOME}}/.ohmyzsh"
else
  ZSH="${XDG_CONFIG_HOME:-${HOME}/.config}/ohmyzsh"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="patrickd"

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

# Temporary fix for git prompts
zstyle ':omz:alpha:lib:git' async-prompt no

# Use iTerm2 shell integration
zstyle ':omz:plugins:iterm2' shell-integration yes

# Set fast-syntax-highlighting theme
export FAST_THEME="q-jmnemonic"

# Disable fzf completion trigger
export FZF_COMPLETION_TRIGGER=''

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  aws
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
  zsh-history-substring-search
  iterm2
  kubectl
  kubernetes
  mkcd
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
  themes
  tmux
  urltools
  uv
  venv
  virtualenv
  yarn
  z
  zshaliases
  zshoptions
  zshparam
  keybindings
  globalias-rev
  clipboard-keybindings
  install-clipcopy
  fast-syntax-highlighting
  zsh-interactive-cd
  zsh-autosuggestions
  zsh-completions
)

# Load oh-my-zsh
#
source "$ZSH/oh-my-zsh.sh"

# Mark 'run-help' for autoloading
#
if alias run-help > /dev/null; then
  unalias run-help
fi
function run-help() {
  autoload -XUz
}
alias help='run-help'

# zsh Z shortcuts
#
if command -v z > /dev/null; then
  alias z-'=z -c'
  alias 'zwhich=z -e'
  alias 'zrecent=z -t'
fi

# Set completion keys
#
bindkey '^I' expand-or-complete
bindkey '^@' zic-completion

# Configure man pager
#
if test -n "${MANPAGER}"; then
  export MANPAGER
elif command -v nvim > /dev/null; then
  export MANPAGER="${MANPAGER:-nvim '+Man!'}"
elif command -v vim > /dev/null; then
  export MANPAGER="${MANPAGER:-vim -M +MANPAGER -}"
elif command -v bat > /dev/null; then
  export MANPAGER="${MANPAGER:-bat --language=Manpage --paging=always --color=always --style=grid,numbers --pager='less ${LESS:-"-XQFR --ignore-case --mouse"}' -- -}"
fi

# Set fzf default options
#
if test -n "${FZF_DEFAULT_OPTS_FILE+X}"; then
  export FZF_DEFAULT_OPTS_FILE
  fzf_default_opts=( "${(f)$(< "${FZF_DEFAULT_OPTS_FILE}")[@]}" )
elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzfrc"; then
  export FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzfrc"
  fzf_default_opts=( "${(f)$(< "${FZF_DEFAULT_OPTS_FILE}")[@]}" )
elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/fzfrc"; then
  export FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/fzfrc"
  fzf_default_opts=( "${(f)$(< "${FZF_DEFAULT_OPTS_FILE}")[@]}" )
elif test -f "${HOME}/.fzfrc"; then
  export FZF_DEFAULT_OPTS_FILE="${HOME}/.fzfrc"
  fzf_default_opts=( "${(f)$(< "${FZF_DEFAULT_OPTS_FILE}")[@]}" )
else
  export -T FZF_DEFAULT_OPTS fzf_default_opts " "
  fzf_default_opts=(
  '--sort'
  '--cycle'
  '--smart-case'
  '--style='\''default'\'''
  '--layout='\''reverse'\'''
  '--tmux='\''bottom,40%,border-native'\'''
  '--info='\''hidden'\'''
  '--border='\''sharp'\'''
  '--input-border='\''line'\'''
  '--header-border='\''line'\'''
  '--preview-border='\''sharp'\'''
  '--no-list-border'
  '--color='\''dark,fg:5,fg+:1:bold,hl:3,hl+:3:bold,bg:-1,bg+:-1:bold,pointer:2:bold,border:3,query:-1:regular,prompt:2:bold,input-border:3,header:2,header-border:3,footer:6,footer-border:3,info:-1:dim,gutter:-1:bold'\'''
  '--bind='\''shift-up:first'\'''
  '--bind='\''shift-down:last'\'''
  '--bind='\''alt-left:backward-word'\'''
  '--bind='\''alt-right:forward-word'\'''
  '--bind='\''ctrl-b:page-up'\'''
  '--bind='\''ctrl-f:page-down'\'''
  '--bind='\''ctrl-\\:bg-cancel'\'''
  '--bind='\''ctrl-j:accept-or-print-query'\'''
  '--bind='\''ctrl-s:replace-query'\'''
  '--bind='\''insert:replace-query'\'''
  '--bind='\''ctrl-/:toggle-preview'\'''
  '--bind='\''ctrl-]:jump-accept'\'''
  '--jump-labels='\''1234567890qwertyuiopasdfghjklzxcvbnm'\'''
  )
fi

# Fzf completion opts
export -T FZF_COMPLETION_OPTS fzf_completion_opts " "
fzf_completion_opts=(
  "${fzf_default_opts[@]}"
  '--select-1'
  '--exit-0'
  '--layout='\''reverse-list'\'''
  '--bind='\''ctrl-o:execute-silent(printf %s {} | { clipcopy || wl-copy || xclip -sel clipboard; })'\'''
)

export -T FZF_CTRL_R_OPTS fzf_ctrl_r_opts " "
fzf_ctrl_r_opts=(
  "${fzf_default_opts[@]}"
  '--filepath-word'
  '--layout='\''reverse-list'\'''
  '--bind='\''ctrl-x:become%zsh -c $@ -- {2..}%'\'''
  '--bind='\''ctrl-o:execute-silent(printf %s {2..} | { clipcopy || wl-copy || xclip -sel clipboard; })'\'''
)

export -T FZF_CTRL_T_OPTS fzf_ctrl_t_opts " "
fzf_ctrl_t_opts=(
  "${fzf_default_opts[@]}"
  '--filepath-word'
  '--no-sort'
  '--bind='\''ctrl-m:become%open_command -- {}%'\'''
  '--bind='\''ctrl-x:become%"${EDITOR:-vim}" -- {}%'\'''
  '--bind='\''ctrl-o:execute-silent(printf %s {} | { clipcopy || wl-copy || xclip -sel clipboard; })'\'''
)

export -T FZF_ALT_C_OPTS fzf_alt_c_opts " "
fzf_alt_c_opts=(
  "${fzf_default_opts[@]}"
  '--no-sort'
  '--filepath-word'
  '--bind='\''ctrl-x:become%"${EDITOR:-nvim}" -- {}%'\'''
  '--bind='\''ctrl-o:execute-silent(printf %s {} | { clipcopy || wl-copy || xclip -sel clipboard; })'\'''
)

# Setup cursor-agent shell integration
#
if command -v cursor-agent > /dev/null; then
  eval "$(cursor-agent shell-integration zsh)"
fi

# Use this prompt if we have it
#
if command -v starship > /dev/null; then
  eval "$(starship init zsh)"
fi

# vi:et:ft=zsh:sts=2:sw=2:ts=8:tw=0
