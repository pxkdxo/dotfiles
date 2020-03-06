# I you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${XDG_CONFIG_HOME:-${HOME}/.config}/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="space-travel"

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
# DISABLE_AUTO_UPDATE="true"

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
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  aliases
  command-not-found
  cargo
  copybuffer
  copydir
  copyfile
  django
  docker
  docker-shortcuts
  encode64
  extract
  fancy-ctrl-z
  git
  gpg-agent
  history-substring-search
  jsontools
  keybindings
  nmap
  npm
  pass
  pip
  ripgrep
  rsync
  rust
  systemadmin
  systemd
  tmux
  ufw
  urltools
  venv
  virtualenv
  zsh-completions
  zsh-navigation-tools
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Zsh Options

setopt NO_ALWAYS_TO_END
setopt APPEND_CREATE
setopt APPEND_HISTORY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt AUTO_NAME_DIRS
setopt NO_BEEP
setopt BRACE_CCL
setopt C_BASES
setopt C_PRECEDENCES
setopt CDABLE_VARS
setopt CHASE_LINKS
setopt NO_CLOBBER
setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD
setopt GLOB_COMPLETE
setopt CORRECT
setopt EXTENDED_GLOB
setopt EXTENDED_HISTORY
setopt NO_GLOB_DOTS
setopt GLOB_STAR_SHORT
setopt NO_GLOBAL_EXPORT
setopt HASH_EXECUTABLES_ONLY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_LEX_WORDS
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_SUBST_PATTERN
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt LONG_LIST_JOBS
setopt MAGIC_EQUAL_SUBST
setopt NOHUP
setopt NOTIFY
setopt NUMERIC_GLOB_SORT
setopt OCTAL_ZEROES
setopt PROMPT_BANG
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS
setopt RC_QUOTES
setopt REMATCH_PCRE
setopt RM_STAR_SILENT
setopt NO_SH_WORD_SPLIT
setopt SHARE_HISTORY
setopt UNSET
setopt WARN_CREATE_GLOBAL


# Zsh Variables

DIRSTACKSIZE=20
LISTMAX=0
HISTORY_IGNORE='([bf]g)'
HISTSIZE=20000
SAVEHIST=15000
NULLCMD=':'
PROMPT_EOL_MARK='%B%S^@%s%b'
if VIMRUNTIME="$(nvim --headless --cmd ':echo $VIMRUNTIME|:q' 2>&1)"
then
  READNULLCMD="${VIMRUNTIME}/macros/less.sh"
else
  READNULLCMD="${PAGER:-${READNULLCMD:-less}}"
fi
unset -v VIMRUNTIME


# Zsh Completion

# Rehash upon completion so programs are found immediately after installation
function _force_rehash
{
  emulate -L zsh
  if (( CURRENT == 1 )) rehash
  return 1
}

zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _match _approximate _ignored _files
zstyle ':completion:*' completions true
zstyle ':completion:*' condition false
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' glob true
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS%:}"
zstyle ':completion:*' list-prompt '%S[%p] -- TAB for more --%s'
zstyle ':completion:*' match-original both
zstyle ':completion:*' matcher-list '' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' old-menu false
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt '%S[%m]%s'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' verbose true
zstyle ':completion:*' word true
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:options' description yes
zstyle ':completion:*:sudo:*' environ PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches%{\e[0m%}'
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'
zstyle ':completion:*:*:-command-:*:commands' ignored-patterns '*\~'
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '[_.]*'
zstyle -e ':completion:*:' max-errors 'reply=( $(( (${#PREFIX//._-/} + ${#SUFFIX//.}) / 5 )) numeric )'

zstyle ':compinstall' filename "$0"
autoload -U -z compinit

compinit -C -d "${ZDOTDIR}/.zcompdump"


# fzf
if [[ -d ${XDG_DATA_HOME:-${HOME}/.local/share}/fzf ]]
then
  # fzf executable
  if [[ :${PATH}: != *:${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/bin:* ]]
  then
    export PATH="${PATH:+${PATH}:}${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/bin"
  fi
  # fzf completions
  if [[ $- == *i* ]]
  then
    source "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/shell/completion.zsh" 2> /dev/null
  fi
  # fzf key bindings
  source "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/shell/key-bindings.zsh"
fi

export -T FZF_DEFAULT_OPTS fzf_default_opts ' '

fzf_default_opts=(
  '--ansi'
  '--bind ctrl-\\:cancel'
  '--bind ctrl-space:jump'
  '--bind ctrl-b:page-up'
  '--bind ctrl-f:page-down'
  '--bind ctrl-j:accept'
  '--bind ctrl-k:kill-line'
  '--bind alt-b:backward-word'
  '--bind alt-f:forward-word'
  '--bind alt-j:down'
  '--bind alt-k:up'
  '--bind alt-w:forward-word'
  '--border'
  '--color=dark'
  '--cycle'
  '--filepath-word'
  '--jump-labels=qwertyuiop\[]'
  '--literal'
  '--no-info'
  '--reverse'
  '--tabstop=4'
)

# vi:et:ft=zsh:sts=2:sw=2:ts=8:tw=0
