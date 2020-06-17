# zshrc: zsh initialization script for interactive shells
# I you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# If this is not an interactive shell, abort.
case $- in
  (*i*) ;;
    (*) return ;;
esac

# Path to your oh-my-zsh installation.
export ZSH="${XDG_CONFIG_HOME:-${HOME}/.config}/oh-my-zsh"

export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"

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
  alacritty
  aliases
  command-not-found
  cargo
  cdls
  copybuffer
  copydir
  copyfile
  ctags
  dircolors
  docker
  docker-shortcuts
  encode64
  extract
  fancy-ctrl-z
  fzf
  fzf-extensions
  git
  git-extras
  globalias-rev
  gpg-agent
  history-substring-search
  jsontools
  keybindings
  mkcd
  mkmv
  mvcd
  nmap
  #npm
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
  vagrant
  venv
  virtualenv
  zsh-completions
  zsh-interactive-cd
  zsh-navigation-tools
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

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
# see zshoptions(1)
#
setopt ALWAYS_TO_END
setopt APPEND_CREATE
setopt APPEND_HISTORY
setopt AUTO_CD
setopt AUTO_NAME_DIRS
setopt AUTO_PUSHD
setopt AUTO_RESUME
setopt NO_BEEP
setopt BRACE_CCL
setopt C_BASES
setopt C_PRECEDENCES
setopt CDABLE_VARS
setopt CHASE_LINKS
setopt CHECK_JOBS
setopt NO_CLOBBER
setopt CORRECT
setopt NO_CORRECT_ALL
setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD
setopt EXTENDED_GLOB
setopt EXTENDED_HISTORY
setopt GLOB_COMPLETE
setopt NO_GLOB_DOTS
setopt GLOB_STAR_SHORT
setopt NO_GLOBAL_EXPORT
setopt HASH_EXECUTABLES_ONLY
setopt HIST_ALLOW_CLOBBER
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_LEX_WORDS
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_SUBST_PATTERN
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt LONG_LIST_JOBS
# setopt MAGIC_EQUAL_SUBST
setopt NOHUP
setopt NOTIFY
setopt NUMERIC_GLOB_SORT
setopt OCTAL_ZEROES
# setopt PROMPT_BANG
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_TO_HOME
setopt RC_QUOTES
setopt REMATCH_PCRE
setopt RM_STAR_SILENT
setopt NO_SH_WORD_SPLIT
setopt SHARE_HISTORY
setopt SHORT_LOOPS
setopt UNSET
setopt WARN_CREATE_GLOBAL


# Environment vars
#
if command -v nvim > /dev/null
then
  export MANPAGER="${MANPAGER:-nvim -c 'set ft=man' -}"
  export PAGER="${PAGER:-nvim -c 'set ft=man' -c 'filetype off' -c 'set ft=' -c 'syntax on' -}"
fi
if command -v vim > /dev/null
then
  export MANPAGER="${MANPAGER:-vim -M -c MANPAGER -}"
fi
if command -v bat > /dev/null
then
  export MANPAGER="${MANPAGER:-bat --color always --decorations always --language man --paging always}"
  export BAT_PAGER="${BAT_PAGER:-less ${LESS:--FgiMqRX-2}}"
  export BAT_STYLE="${BAT_STYLE:-changes,grid,numbers}"
  export BAT_THEME="${BAT_THEME:-Sublime Snazzy}"
fi


# Zsh Params
# see zshparam(1)

LISTMAX=0
DIRSTACKSIZE=0
CORRECT_IGNORE='_*'
CORRECT_IGNORE_FILE='*~'
HISTSIZE=25000
SAVEHIST=20000
NULLCMD="${NULLCMD:-cat}"
PROMPT_EOL_MARK='%B%S^@%b%s'
READNULLCMD="${READNULLCMD:-cat}"
sprompt=(
'%N:'
'%1F'"'"'${${:-%%R}//'"'"'/'"'"''''"'""'"'}'"'"'%1f:'
'perhaps you meant'
'%2F'"'"'${${:-%%r}//'"'"'/'"'"''''"'""'"'}'"'"'%2f'
'%8F[%8f%7Fy%7f%8F/%8f%7Fn%7f%8F/%8f%7Fe%7f%8F/%8f%7Fa%7f%8F]%8f: '
)
SPROMPT='${(%%)sprompt}'


# Completion
# see zshcompsys(1)

# Rehash upon completion so programs are found immediately after installation
function _force_rehash() {
  emulate -LR zsh
  if (( CURRENT == 1 )); then rehash; fi
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
zstyle ':completion:*' list-prompt '%S[%U%p%u] -- <%UTab%u> to continue --%s'
zstyle ':completion:*' match-original both
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+r:|[_-]=* r:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' old-menu false
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt '%S[%U%m%u]%s'
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
zstyle ':completion:*:sudo:*' environ "PATH=${$(sudo -n -u "${USER:-$(id -nu)}" printenv PATH):-${PATH:-$(getconf PATH)}}"
zstyle ':completion:*:warnings' format '%B-- %F{red}%Uno matches%u%f --%b'
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'
zstyle ':completion:*:*:-command-:*:commands' ignored-patterns '*\~'
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '(.|_[^_])*'
zstyle -e ':completion:*' max-errors 'reply=( "$(( (${#PREFIX} + ${#SUFFIX} + 1) / 4 ))" numeric )'

# zstyle ':compinstall' filename "$0"
autoload -U -z compinit

compinit -i -d "${ZSH_COMPDUMP:-${ZDOTDIR:-${HOME}}/.zcompdump}"


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
    source -- "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/shell/completion.zsh"
  fi 2> /dev/null
  # fzf key bindings
  source -- "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/shell/key-bindings.zsh"
fi

#export FZF_TMUX=1

export FZF_COMPLETION_TRIGGER=''
bindkey '^]' fzf-completion
bindkey '^I' "${fzf_default_completion}"

typeset -xT FZF_DEFAULT_OPTS fzf_default_opts " "
fzf_default_opts=(
  --bind='''ctrl-\:cancel'''
  --bind='''ctrl-space:jump'''
  --bind='''ctrl-b:page-up'''
  --bind='''ctrl-f:page-down'''
  --bind='''ctrl-j:accept'''
  --bind='''ctrl-k:kill-line'''
  --bind='''ctrl-o:execute-silent(sh -c ''"''"''printf %s "$*" | xclip -sel clip''"''"'' -- {2..})'''
  --color='''header:1,info:3,pointer:5,prompt:5,border:5,fg:4,fg+:6,hl:6,hl+:5'''
  --info=hidden
  --layout=reverse
  --literal
  --tabstop=4
)

typeset -xT FZF_CTRL_R_OPTS fzf_ctrl_r_opts " "
fzf_ctrl_r_opts=(
  --bind='''alt-enter:execute-silent%exec x-terminal-emulator -e tmux new zsh -i -c ''"''"''"${(@Z+c+)@}"''"''"'' -- {2..} &%+abort'''
  --bind='''ctrl-r:toggle-sort'''
  --jump-labels='''qwertyuiop[]'''
  --border
  --filepath-word
  --no-cycle
  --no-hscroll
  --sort
)

typeset -xT FZF_CTRL_T_OPTS fzf_ctrl_t_opts " "
fzf_ctrl_t_opts=(
  --bind='''alt-enter:execute-silent%exec x-terminal-emulator -e tmux new zsh -i -c ''"''"''exec xdg-open "${(@Z+c+)@}"''"''"'' -- {} &%+abort'''
  --bind='''ctrl-r:toggle-sort'''
  --jump-labels='''qwertyuiop[]'''
  --border
  --filepath-word
  --no-cycle
  --no-hscroll
  --no-sort
)

typeset -xT FZF_ALT_C_OPTS fzf_alt_c_opts " "
fzf_alt_c_opts=(
  --bind='''alt-enter:execute-silent%exec x-terminal-emulator -e tmux new zsh -i -c ''"''"''exec "${EDITOR:-editor}" -- "${(@Z+c+)@}"''"''"'' -- {} &%+abort'''
  --bind='''ctrl-r:toggle-sort'''
  --jump-labels='''qwertyuiop[]'''
  --preview='''tree -CFl -- {} | head -n "$((FZF_PREVIEW_LINES))"'''
  --border
  --filepath-word
  --no-cycle
  --no-hscroll
  --no-sort
)

if command -v rg > /dev/null
then
  typeset -xT FZF_DEFAULT_COMMAND fzf_default_command " "
  fzf_default_command_prefix=(
    rg
    --color=auto
    --smart-case
  )
fi


# zsh syntax highlighting

typeset -a ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor pattern)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[alias]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=green'
ZSH_HIGHLIGHT_STYLES[assign]='none'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green,underline'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=red'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=white'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=blue'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=red'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-6]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[command-substitution]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]='none'
ZSH_HIGHLIGHT_STYLES[commandseparator]='bold'
ZSH_HIGHLIGHT_STYLES[comment]='bg=black,bold,standout'
ZSH_HIGHLIGHT_STYLES[cursor]='underline'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bold,underline'
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=cyan'
#ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='none'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=blue'
#ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue'
ZSH_HIGHLIGHT_STYLES[line]='none'
ZSH_HIGHLIGHT_STYLES[named-fd]='underline'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='underline'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=''
ZSH_HIGHLIGHT_STYLES[precommand]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[process-substitution]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[redirection]='underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=red'
ZSH_HIGHLIGHT_STYLES[root]='standout'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='none'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
#ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=white'


# start a tmux session
# if [[ -n ${DISPLAY} && -z ${TMUX} ]] && command -v tmux > /dev/null
# then
#   exec tmux new-session -t ${USER:-$(id -un)} \; new-window
# fi

# vi:et:ft=zsh:sts=2:sw=2:ts=8:tw=0
