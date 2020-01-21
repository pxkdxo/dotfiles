# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${XDG_CONFIG_HOME:-${HOME}/.config}/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="hello-world"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "fox" "funky" "norm" "re5et" "robbyrussell" )

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
ENABLE_CORRECTION="true"

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
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="${ZSH}/custom"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  cdls
  fancy-ctrl-z
  git
  gpg-agent
  mkcd
  mvcd
  nmap
  pass
  pip
  rsync
  shrink-path
  systemadmin
  systemd
)

source "${ZSH}/oh-my-zsh.sh"

# User configuration

# The following lines were added by compinstall
zstyle ':completion:*' completer _list _expand _complete _ignored _match _correct _prefix
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'r:|[._+-]=* r:|=*' '+l:|=* r:|=*'
zstyle ':completion:*' match-original both
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=long
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt '%Smatch %l [%p]%s'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose true
autoload -Uz compinit
#compinit
# End of lines added by compinstall

# see zshoptions(1)
setopt always_to_end
setopt append_create
setopt auto_cd
setopt auto_continue
setopt auto_name_dirs
setopt no_beep
setopt brace_ccl
setopt c_bases
setopt c_precedences
setopt cdable_vars
setopt chase_links
setopt no_clobber
setopt complete_aliases
setopt complete_in_word
setopt correct
setopt no_correct_all
setopt extended_glob
setopt glob_star_short
setopt no_global_export
setopt no_hist_beep
setopt hist_expire_dups_first
setopt hist_fcntl_lock
setopt hist_ignore_dups
setopt hist_lex_words
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_subst_pattern
setopt hist_verify
setopt no_list_beep
setopt long_list_jobs
setopt magic_equal_subst
setopt numeric_glob_sort
setopt octal_zeroes
setopt rc_expand_param
setopt rc_quotes
setopt rematch_pcre
setopt share_history
setopt warn_create_global
setopt warn_nested_var

LISTMAX=0

# Set GPG_TTY to the tty on stdin
GPG_TTY="$(tty)" && export GPG_TTY || unset GPG_TTY

# Refresh gpg-agent in case user switched to an Xsession
gpg-connect-agent updatestartuptty /bye &> /dev/null

# thefuck
if command -v thefuck > /dev/null
then
  eval "$(thefuck --alias)"
fi

# enable vim line editing mode
#bindkey -v

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

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# perform alias expansion on 1st argument
alias nohup='nohup '
alias sudo='sudo '
alias unbuffer='unbuffer '

# general defaults
alias gdb='gdb -q'
alias ls='ls -Cp'
alias mkdir='mkdir -pv'
alias mv='mv -biv'
alias rm='rm -Iv'
alias rmdir='rmdir -v'
alias vim='vim -p'

# print colored output to terminals
alias dir="${aliases[dir]:-dir} --color=auto"
alias egrep="${aliases[egrep]:-egrep} --color=auto"
alias fgrep="${aliases[fgrep]:-fgrep} --color=auto"
alias grep="${aliases[grep]:-grep}  --color=auto"
alias ls="${aliases[ls]:-ls} --color=auto"
alias vdir="${aliases[vdir]:-vdir} --color=auto"

# go back to previous directory
alias -- -='cd -'

# clear
alias c='clear'

# vim
alias v='vim'

# dirstack
alias ds='dirs'
alias po='popd'
alias pu='pushd'

# jobs
alias j='jobs -p'

# thefuck
if command -v fuck > /dev/null; then alias fk='fuck'; fi

# ls
alias l='ls'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'

# python
alias py='python'
alias py2='python2'
alias py3='python3'
alias python='python3'
alias pip='pip3'
#alias pep8='pep8 2> /dev/null'

# systemd
if command -v systemctl > /dev/null
then
  alias scl='systemctl'
  alias jcl='journalctl'
  alias sclu='systemctl --user'
  alias jclu='journalctl --user'
fi

# tmux
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux ls'
alias tn='tmux new'

# htop
if command -v htop > /dev/null; then alias top='htop'; fi

# xclip
if command -v xclip > /dev/null
then
  alias xb='xclip -sel clipboard'
  alias xb-strip-l='xb -o | sed '"'"'s,^[ \t]*,,'"'"' | xb'
  alias xb-strip-r='xb -o | sed '"'"'s,[ \t]*$,,'"'"' | xb'
  alias xb-strip='xb -o | sed '"'"'s,^[ \t]*\|[ \t]*$,,'"'"' | xb'
  alias xb1='xclip -sel primary'
  alias xb1-strip-l='xb1 -o | sed '"'"'s,^[ \t]*,,'"'"' | xb1'
  alias xb1-strip-r='xb1 -o | sed '"'"'s,[ \t]*$,,'"'"' | xb1'
  alias xb1-strip='xb1 -o | sed '"'"'s,^[ \t]*\|[ \t]*$,,'"'"' | xb1'
  alias xb2='xclip -sel secondary'
  alias xb2-strip-l='xb2 -o | sed '"'"'s,^[ \t]*,,'"'"' | xb2'
  alias xb2-strip-r='xb2 -o | sed '"'"'s,[ \t]*$,,'"'"' | xb2'
  alias xb2-strip='xb2 -o | sed '"'"'s,[ \t]*\|[ \t]*$,,'"'"' | xb2'
fi

# find non-recursively in the current directory
alias find.='find . -mindepth 1 -maxdepth 1'

# send PulseAudio input to output
alias paloop='pacmd load-module module-loopback latency_msec=8'

# query DNS servers for my WAN IP
alias wanip='dig @resolver1.opendns.com ANY myip.opendns.com +short'
alias wanip4='dig @resolver1.opendns.com -4 myip.opendns.com +short'
alias wanip6='dig @resolver1.opendns.com -6 myip.opendns.com +short'

# scp to Holberton servers
function scp-web-01
{
  scp "$@" ubuntu@web-01:
}
function scp-web-02
{
  scp "$@" ubuntu@web-02:
}
function scp-lb-01
{
  scp "$@" ubuntu@lb-01:
}
