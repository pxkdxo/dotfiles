# ~/.bashrc: bash(1) startup script for interactive shells

# Stop if this is a non-interactive shell
[[ $- == *i* ]] || return 0

# Make a cache directory for shell data (e.g. history, hash table, etc.)
[[ -z ${BASH_CACHE_DIR=${XDG_CACHE_HOME:-${HOME}/.cache}/bash} ]] ||
  if [[ -d ${BASH_CACHE_DIR} ]] || mkdir -m 0700 -p -- "${BASH_CACHE_DIR}"
  then
    export BASH_CACHE_DIR
  else
    unset 'BASH_CACHE_DIR'
  fi

# Synchronize LINES and COLUMNS with window after each command
shopt -s checkwinsize
# Send the shell SIGWINCH (28) to initialize LINES and COLUMNS
kill -s WINCH "$$" 2> /dev/null

# Require the redirection operator `>|' to overwrite files
set -o noclobber
# Report the status of terminated background jobs immediately
set -o notify
# Do not resolve symbolic links during execution of builtins
set -o physical

# Pass directory names given as commands as arguments to cd
shopt -s autocd
# Expand directory names upon performing filename completion
shopt -s direxpand
# Correct mispelled directory names during word completion
shopt -s dirspell
# Enable programmable completion facilities
shopt -s progcomp

# Check that hashed commands actually exist before executing them
shopt -s checkhash
# Show active jobs before exiting and request confirmation to exit
shopt -s checkjobs
# Send SIGHUP to all jobs when interactive login shells exit
shopt -s huponexit
# Command substitutions inherit the value of the 'errexit' option
shopt -s inherit_errexit

# Ignore locale collating sequence when matching range expressions
shopt -s globasciiranges
# Enable extended pattern matching syntax
shopt -s extglob
# ``**'' matches all files and zero or more directories and subdirectories
shopt -s globstar

# Ignore shared-object libraries found while searching for executables
EXECIGNORE='?(/usr?(/local))/lib?(?(x)@(32|64))/**/*.so*(.+([[:digit:]]))'

# Don't match paths with basename `.' or `..'
GLOBIGNORE='*(?(.)*/).?(.)*(/)'
# Setting GLOBIGNORE sets 'dotglob' so unset it
shopt -u dotglob

# Configure the location of the history file
if [[ -d ${BASH_CACHE_DIR} ]]
then
  HISTFILE="${BASH_CACHE_DIR}/history"
else
  HISTFILE="${HOME}/.bash_history"
fi

# Number of entries that may be kept in memory
HISTSIZE=65536
# Number of entries that may be kept on disk
HISTFILESIZE=-1
# Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'
# Ignore blanks surrounding immediate duplicates
HISTIGNORE='*([[:blank:]])@(&|fg|bg|[[:blank:]])*([[:blank:]])'

# Append to the history file instead of overwriting it
shopt -s histappend
# Try to save multiline commands as single entries
shopt -s cmdhist
# With 'cmdhist' enabled, save commands w/ embedded newlines
shopt -s lithist
# With readline, load failed history subs into buffer for editing
shopt -s histreedit
# With readline, load history sub results into buffer for editing
shopt -s histverify

lower=( {a..z} )
upper=( {A..Z} )
digit=( {0..9} )
letter=( "${lower[@]}" "${upper[@]}" )
word=( "${digit[@]}" "${letter[@]}" '_' )
punct=(
'!' '"' '#' '$' '%' '&' "'" '(' ')' '*' '+'
',' '-' '.' '/' ':' ';' '<' '=' '>' '?' '@'
'[' '\' ']' '^' '_' '`' '{' '|' '}' '~' 
)

# Match and remove debug traps from bash-preexec 
__bp_preexec_re="'"$'((.*)[;\n])?[ \t]*__bp_[[:alnum:]_]*[ \t]*([;\n](.*))?'"'"
if [[ $(trap -p DEBUG) =~ ${__bp_preexec_re} ]]
then
  case "${BASH_REMATCH[2]}"$'\n'"${BASH_REMATCH[4]}" in
    ?*$'\n'?*)
      trap "${BASH_REMATCH[2]}"$'\n'"${BASH_REMATCH[4]}" DEBUG ;;
    ?*$'\n')
      trap "${BASH_REMATCH[2]}" DEBUG ;;
    $'\n'?*)
      trap "${BASH_REMATCH[4]}" DEBUG ;;
    $'\n')
      trap DEBUG ;;
  esac
fi

# Remove bash-prexec from PROMPT_COMMAND
PROMPT_COMMAND="${PROMPT_COMMAND//*([[:blank:]])__@(bp|pc)_*([[:alnum:]_])*([[:blank:]])*([;$'\n'])}"
PROMPT_COMMAND="${PROMPT_COMMAND##*([[:space:];])}"
PROMPT_COMMAND="${PROMPT_COMMAND%%*([[:space:];])}"

PROMPT_COMMAND='__pc_precmd; '"${PROMPT_COMMAND:+${PROMPT_COMMAND};}"

trap '__pc_preexec "${_}"' USR1

precmd_functions=( "${precmd_functions[@]}" )
preexec_functions=( "${preexec_functions[@]}" )

# Invoke precmd functions
__pc_precmd() {
  __pc_set_exit_status
  __pc_invoke "${precmd_functions[@]}"
}

# Invoke preexec functions
__pc_preexec() {
  __pc_invoke "${preexec_functions[@]}"
}

# Set the exit status
__pc_set_exit_status() {
  return "$(( __pc_last_exit_status = $(( ${1:-$?} )) ))"
}

# Invoke commands
__pc_invoke() {
  while (( $# ))
  do
    if command -v "$1" 1>/dev/null
    then
      __pc_set_exit_status __pc_last_exit_status
      "$1"
    fi
    shift
  done
  return "$(( __pc_last_exit_status ))"
}

# Add functions to the precmd array
add_precmd_functions() {
  while (( $# ))
  do
    if (IFS=':' && [[ ":${precmd_functions[*]}:" != *:"$1":* ]])
    then
      precmd_functions+=( "$1" )
    fi
    shift
  done
  precmd_functions=( "${precmd_functions[@]}" )
}

# Add functions to the preexec array
add_preexec_functions() {
  while (( $# ))
  do
    if (IFS=':' && [[ ":${preexec_functions[*]}:" != *:"$1":* ]])
    then
      preexec_functions+=( "$1" )
    fi
    shift
  done
  preexec_functions=( "${preexec_functions[@]}" )
}

# Remove functions from the precmd array
remove_precmd_functions() {
  while (( $# ))
  do
    for _ in "${!precmd_functions[@]}"
    do
      if [[ $1 = "${precmd_functions[_]}" ]]
      then
        unset -v 'precmd_functions[_]'
      fi
    done
    shift
    precmd_functions=( "${precmd_functions[@]}" )
  done
}

# Remove functions from the preexec array
remove_preexec_functions() {
  while (( $# ))
  do
    for _ in "${!preexec_functions[@]}"
    do
      if [[ $1 = "${preexec_functions[_]}" ]]
      then
        unset -v 'preexec_functions[_]'
      fi
    done
    shift
    preexec_functions=( "${preexec_functions[@]}" )
  done
}


# Initialize a dictionary to hold terminfo data
declare -A ti=( )

# Limit depth of paths produced by '\w' upon prompt expansion
PROMPT_DIRTRIM=2

# Set the pre-execution prompt
__PS0_update() {
  PS0='$(kill -s SIGUSR1 "$$")'
}

# Set the primary prompt
__PS1_update() {
  PS1=\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\['"${ti[dim]:=$( tput dim )}"'\]'\
'\['"$*"'\]'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\u'\
'\['"${ti[dim]:=$(tput dim || tput setaf 245)}"'\]'\
'@'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\h'\
'\['"${ti[dim]:=$(tput dim || tput setaf 245)}"'\]'\
':'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\w'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\n'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\['"$*"'\]'\
'\$>'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
' '
}

# Set the secondary prompt
__PS2_update() {
  PS2=\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\['"$*"'\]'\
'$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') / 10 ))'\
'$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') % 10 ))'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
' '
}

# Set the select prompt
__PS3_update() {
  PS3='?> '
}

# Set the execution-trace prompt
__PS4_update() {
  PS4='.> '
}

# Update the prompt strings
__PS_update() {
  set -- "$?" "$(
    case "$?" in
      (0) ;;
      (*) tput setaf "$(( ($? - 1) % 8 + 1 ))" 2>/dev/null
    esac
  )"
  __PS0_update "$2"
  __PS1_update "$2"
  __PS2_update "$2"
  __PS3_update "$2"
  __PS4_update "$2"
}

# Add to precmd functions
add_precmd_functions __PS_update


# Configure window title
if [[ ${TERM} == @(rxvt|vte|xterm)?(-*) ]]
then
  __window_title_precmd()
  {
    TTY="$(tty)"
    WINDOW_TITLE="${TTY##/dev/}) \\u@\\h (\${0##*/})"
  }

  __window_title_preexec()
  {
    TTY="$(tty)"
    WINDOW_TITLE="(${TTY##/dev/}) \\u@\\h (\\W)"
    printf '\e]0;%s\a' "${WINDOW_TITLE@P}"
  }
  add_precmd_functions __window_title_precmd
  add_preexec_functions __window_title_preexec

elif [[ ${TERM} == @(screen|tmux)?(-*) ]]
then
  __window_title_precmd()
  {
    TTY="$(tty)"
    WINDOW_TITLE="${TTY##/dev/}) \\u@\\h (\${0##*/})"
    printf '\ek%s\e\' "${WINDOW_TITLE@P}"
  }

  __window_title_preexec()
  {
    TTY="$(tty)"
    WINDOW_TITLE="(${TTY##/dev/}) \\u@\\h (\\W)"
    printf '\ek%s\e\' "${WINDOW_TITLE@P}"
  }
  add_precmd_functions __window_title_precmd
  add_preexec_functions __window_title_preexec
fi


# Set GPG_TTY to device on stdin and add it to the environment
GPG_TTY="$(tty)" || GPG_TTY="" && export GPG_TTY || unset -v GPG_TTY

# Refresh gpg-agent in case we switched to an Xsession
gpg-connect-agent updatestartuptty /bye &>/dev/null


# Load thefuck
if command -v thefuck 1>/dev/null
then
  eval "$(thefuck --alias)"
fi


# Make less more friendly for non-text input files
if command -v lesspipe 1>/dev/null
then
  eval "$(SHELL="${SHELL:-$(type -P bash)}" lesspipe)"
fi


# Load bash-completion unless posix mode is set
if ! shopt -oq posix
then
  if [[ -f /usr/share/bash-completion/bash_completion ]]
  then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]
  then
    source /etc/bash_completion
  fi
fi


# Load bash_aliases file if it exists
if [[ -f ~/.bash_aliases ]]
then
  source ~/.bash_aliases
fi


# sourcedir - recursively source a directory
sourcedir()
{
  if [[ -d $1 ]]
  then
    for _ in "$1"/*
    do
      "${FUNCNAME[0]}" "${_}" "${@:2}"
    done
    return
  fi
  if [[ -f $1 ]]
  then
    source -- "$@"
    return
  fi
}


# Source additional init scripts
if [[ -d ~/.bashrc.d ]]
then
  sourcedir ~/.bashrc.d
fi
