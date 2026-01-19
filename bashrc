#!/usr/bin/env bash
# ~/.bashrc: bash(1) startup script for interactive shells

# Stop if this is a non-interactive shell
[[ $- == *i* ]] || return 0

# Make a cache directory for shell data (e.g. history, hash table, etc.)
BASH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/bash"
if mkdir -p -- "${BASH_CACHE_DIR}"
then
  export BASH_CACHE_DIR
else
  unset -v BASH_CACHE_DIR
fi 2> /dev/null

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

if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]
then
  # Pass directory names given as commands as arguments to cd
  shopt -s autocd
  # Expand directory names upon performing filename completion
  shopt -s direxpand
  # Correct mispelled directory names during word completion
  shopt -s dirspell
  # Ignore locale collating sequence when matching range expressions
  shopt -s globasciiranges
  # ``**'' matches all files and zero or more directories and subdirectories
  shopt -s globstar
  # Show active jobs before exiting and request confirmation to exit
  shopt -s checkjobs
  # Command substitutions inherit the value of the 'errexit' option
  shopt -s inherit_errexit
fi

# Check that hashed commands actually exist before executing them
shopt -s checkhash
# Send SIGHUP to all jobs when interactive login shells exit
shopt -s huponexit
# Enable extended pattern matching syntax
shopt -s extglob

# Enable programmable completion facilities
shopt -s progcomp

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
HISTSIZE=9999
# Number of entries that may be kept on disk
HISTFILESIZE=-1
# Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'
# Ignore blanks surrounding immediate duplicates
HISTIGNORE='*([[:blank:]])@(&|@([[:blank:]]|fc|fg|bg)?([[:blank:]]*))*([[:blank:]])'

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

# Change the window title of X terminals
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
    ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

# Enable colors for ls, etc
if command -v dircolors 1> /dev/null
then
  if test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors"
then
    eval "$(dircolors -b -- "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors")"
  elif test -f ~/.dircolors
then
    eval "$(dircolors -b -- ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

# Set prompt based on whether or not this is running as root
if [[ ${EUID} == 0 ]] 
then
  PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
else
  PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
fi

# Match and remove debug traps set by bash-preexec
__disable_bp_debug_trap() {
  # shellcheck disable=SC2064
  trap "
$(
    __trap_return="$(trap -p RETURN)"
    printf '%s\n' "${__trap_return:-trap RETURN}"
)
$(
    __bp_debug_trap_re=\'$'((.*)[;&\n])?[ \t]*__bp_[[:alnum:]_]*[ \t]*([;&\n](.*))?'\'
    __bp_debug_trap_context_re=$'^[[:space:]]*((.*[[:graph:]])?)[[:space:]]*\n[[:space:]]*((.*[[:graph:]])?)[[:space:]]*$'
    if [[ "$(trap -p DEBUG)" =~ ${__bp_debug_trap_re} ]]
then
      __debug_trap_matched="${BASH_REMATCH[2]}"$'\n'"${BASH_REMATCH[4]}"
      if [[ "${__debug_trap_matched}" =~ ${__bp_debug_trap_context_re} ]]
then
        # shellcheck disable=SC2064
        printf 'trap %q%q DEBUG\n' "${BASH_REMATCH[1]:+${BASH_REMATCH[1]}\n}" "${BASH_REMATCH[3]:+${BASH_REMATCH[3]}\n}"
      fi
    fi
)
  " RETURN
}
declare -ft __disable_bp_debug_trap
if [[ $- == *T* ]]
then
  __disable_bp_debug_trap
else
  trap '' DEBUG
fi

# Remove bash-prexec from PROMPT_COMMAND
PROMPT_COMMAND="${PROMPT_COMMAND//*([[:blank:]])__@(bp|pc)_*([[:alnum:]_])*(+([[:blank:]])+([^[:graph:]]))*([[:blank:]])?([;&])*([[:space:]])}"
PROMPT_COMMAND="${PROMPT_COMMAND##*([[:space:];&])}"
PROMPT_COMMAND="${PROMPT_COMMAND%%*([[:space:];&])}"

PROMPT_COMMAND="__pc_precmd${PROMPT_COMMAND:+"; ${PROMPT_COMMAND}"}"

trap '__pc_preexec "${_}"' USR1

precmd_functions=( "${precmd_functions[@]}" )
preexec_functions=( "${preexec_functions[@]}" )

# Invoke precmd functions
__pc_precmd() {
  __pc_set_exit_status "$?"
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
    if command -v -- "$1" 1> /dev/null
    then
      __pc_set_exit_status "${__pc_last_exit_status}"
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
__ti_dim="$(tput dim)"
__ti_bold="$(tput bold)"
__ti_sitm="$(tput sitm)"
__ti_ritm="$(tput ritm)"
__ti_smso="$(tput smso)"
__ti_rmso="$(tput rmso)"
__ti_smul="$(tput smul)"
__ti_rmul="$(tput rmul)"
__ti_sgr0="$(tput sgr0)"
__ti_colors="$(tput colors)"
declare -a fg=()
declare -a bg=()
while (( ${#fg[@]} < ${__ti_colors:-8} ))
do
  fg[${#fg[@]}]="$(tput setaf "${#fg[@]}")"
  bg[${#bg[@]}]="$(tput setag "${#bg[@]}")"
done



# Limit depth of paths produced by '\w' upon prompt expansion
PROMPT_DIRTRIM=2

# Program the pre-execution prompt to send SIGUSR1
ps0_update() {
  # shellcheck disable=SC2016,SC2034
  PS0='$(kill -s SIGUSR1 "$$")'
  return "$(($1))"
}

# Set the primary prompt
ps1_update() {
PS1="\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
\\u\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}${1:+${__ti_fg[$(($1)) % 8]}}\\]\
@\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
\\h\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}${1:+${__ti_fg[$(($1)) % 8]}}\\]\
:\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
\\w\
\\[${__ti_sgr0:=$(tput sgr0)}\\]\
\\n\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
\$>\
\\[${__ti_sgr0:=$(tput sgr0)}\\] "
}

# Set the secondary prompt
if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]
then
ps2_update() {
PS2="\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
$(( (LINENO - $(( BASH_LINENO[-1] ))) / 10 ))\
$(( (LINENO - $(( BASH_LINENO[-1] ))) % 10 ))\
\\[${__ti_sgr0:=$(tput sgr0)}\] "
}

else
ps2_update() {
PS2="\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
.>\
\\[${__ti_sgr0:=$(tput sgr0)}\] "
}
fi

# Set the select prompt
ps3_update() {
PS3="\
\\[${__ti_sgr0:=$(tput sgr0)}${__ti_bold:=$(tput bold)}\\]\
*>\
\\[${__ti_sgr0:=$(tput sgr0)}\\] "
}

# Set the execution-trace prompt
ps4_update() {
PS4='+> '
}

# Update the prompt strings
ps_update() {
  local __entry_status="${?#0}"
  ps0_update "${__entry_status}"
  ps1_update "${__entry_status}"
  ps2_update "${__entry_status}"
  ps3_update "${__entry_status}"
  ps4_update "${__entry_status}"
  return "${__entry_status:-0}"
}

# Add to precmd functions
add_precmd_functions ps_update


# Configure window title
if [[ ${TERM} == @(rxvt|vte|xterm)?(-*) ]]
then
  __window_title_precmd() {
    TTY="$(tty)"
    WINDOW_TITLE="${TTY##/dev/}) \\u@\\h (\${0##*/})"
  }
  __window_title_preexec() {
    TTY="$(tty)"
    WINDOW_TITLE="(${TTY##/dev/}) \\u@\\h (\\W)"
    printf '\e]0;%s\a' "${WINDOW_TITLE@P}"
  }
  #add_precmd_functions __window_title_precmd
  add_preexec_functions __window_title_preexec

elif [[ ${TERM} == @(screen|tmux)?(-*) ]]
then
  # shellcheck disable=SC1003
  __window_title_precmd() {
    TTY="$(tty)"
    WINDOW_TITLE="${TTY##/dev/}) \\u@\\h (\${0##*/})"
    printf '\ek%s\e\' "${WINDOW_TITLE@P}"
  }
  # shellcheck disable=SC1003
  __window_title_preexec() {
    TTY="$(tty)"
    WINDOW_TITLE="(${TTY##/dev/}) \\u@\\h (\\W)"
    printf '\ek%s\e\' "${WINDOW_TITLE@P}"
  }
#add_precmd_functions __window_title_precmd
add_preexec_functions __window_title_preexec
fi

if command -v gpg-agent > /dev/null 2>&1
then
  # Set GPG_TTY to device on stdin
  if [[ -t 0 ]]
then
    if GPG_TTY="$(tty 2> /dev/null)"
then
      export GPG_TTY
    else
      unset -v GPG_TTY
    fi
  fi
  # Refresh gpg-agent in case we switched to an X-session
  gpg-connect-agent updatestartuptty /bye 1> /dev/null 2>&1
fi

# command-not-found hook
command_not_found_handle() {
  if command -v cnf-lookup > /dev/null
then
    if test -t 1
then
      cnf-lookup --colors -- "${@::1}"
    else
      cnf-lookup -- "${@::1}"
    fi
  elif test -x ~/.local/lib/command-not-found
then
    ~/.local/lib/command-not-found --no-failure-msg -- "${@::1}"
  elif test -x /usr/local/lib/command-not-found
then
    /usr/local/lib/command-not-found --no-failure-msg -- "${@::1}"
  elif test -x /usr/lib/command-not-found
then
    /usr/lib/command-not-found --no-failure-msg -- "${@::1}"
  elif test -x /lib/command-not-found
then
    /lib/command-not-found --no-failure-msg -- "${@::1}"
  else
    printf '%s: command not found\n' "${@::1}"
  fi >&2
  return 127
}

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


# sourcer - source directories too
sourcer() {
  local subpath
  local sourcepath="$1"
  shift
  if [[ -d ${sourcepath} ]]
  then
    for subpath in "${sourcepath}"/*
    do
      sourcer "${subpath}" "$@"
    done
  elif [[ -f ${sourcepath} ]]
  then
    source -- "$@"
  fi
}

# Source additional startup scripts
#if [[ -d ~/.bashrc.d ]]
#then
#  sourcer ~/.bashrc.d
#fi

. "$HOME/.local/share/../bin/env"
