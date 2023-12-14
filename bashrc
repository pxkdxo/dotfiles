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

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

xhost +local:root > /dev/null 2>&1

# Match and remove debug traps set by bash-preexec
__disable_bp_debug_trap() {
  # shellcheck disable=SC2064
  trap "
  $(: "$(trap -p RETURN)"
    printf '%s\n' "${_:-trap RETURN}")
  $(__bp_debug_trap_re="'"$'((.*)[;\n])?[ \t]*__bp_[[:alnum:]_]*[ \t]*([;\n](.*))?'"'"
    __bp_debug_trap_context_re=$'^[ \t\n]*((.*[[:graph:]])?)[ \t\n]*\n[ \t\n]*((.*[[:graph:]])?)[ \t\n]*$'
    [[ $(trap -p DEBUG) =~ ${__bp_debug_trap_re} && ${BASH_REMATCH[2]}$'\n'${BASH_REMATCH[4]} =~ ${__bp_debug_trap_context_re} ]]
    # shellcheck disable=SC2064
    printf 'trap %q DEBUG\n' "${BASH_REMATCH[1]:+${BASH_REMATCH[1]$'\n'}}${BASH_REMATCH[3]:+${BASH_REMATCH[3]$'\n'}}")
  " RETURN
}
declare -ft __disable_bp_debug_trap
if [[ $- == *T* ]]
then
  __disable_debug_trap
else
  trap '' DEBUG
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
declare -A ti=( )

# Limit depth of paths produced by '\w' upon prompt expansion
PROMPT_DIRTRIM=2

# Set the pre-execution prompt to trigger SIGUSR1
__PS0_update() {
  # shellcheck disable=SC2016,SC2034
  PS0='$(kill -s SIGUSR1 "$$")'
  return "$(($1))"
}

# Set the primary prompt
__PS1_update() {
  PS1="\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'\u'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'\['"${1:+$(tput setaf "$(( ($1) % 8 ))")}"'\]'"\
"'@'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'\h'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'\['"${1:+$(tput setaf "$(( ($1) % 8 ))")}"'\]'"\
"':'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'\w'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\n'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'\$>'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"' '
  return "$(($1))"
}

# Set the secondary prompt
__PS2_update() {
  PS2="\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"'\['"${ti[bold]:=$(tput bold)}"'\]'"\
"'$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') / 10 ))'"\
"'$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') % 10 ))'"\
"'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'"\
"' '
  return "$(($1))"
}

# Set the select prompt
__PS3_update() {
  PS3='*) '
  return "$(($1))"
}

# Set the execution-trace prompt
__PS4_update() {
  PS4='.> '
  return "$(($1))"
}

# Update the prompt strings
__PS_update() {
  for _ in {0..4}
  do
    "__PS${_}_update" "${?#0}"
  done
}

# Add to precmd functions
add_precmd_functions __PS_update


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

# Set GPG_TTY to device on stdin and add it to the environment
[[ -t 0 ]] && GPG_TTY=$(tty) || export GPG_TTY=''

# Refresh gpg-agent in case we switched to an Xsession
gpg-connect-agent updatestartuptty /bye 1> /dev/null 2>&1


# Load thefuck
if command -v thefuck 1> /dev/null
then
  eval "$(thefuck --alias)"
fi


# Make less more friendly for non-text input files
if command -v lesspipe 1> /dev/null
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


#
# # extract - archive extractor
# # usage: extract <file>
extract ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
# sourcedir - recursively source a directory
sourcedir()
{
  if [[ -d $1 ]]
  then
    for _ in "$1"/*
    do
      "${FUNCNAME[0]}" "${_}" "${@:2}"
    done
  elif [[ -f $1 ]]
  then
    source -- "$@"
  fi
}


# Source additional init scripts
if [[ -d ~/.bashrc.d ]]
then
  sourcedir ~/.bashrc.d
fi

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/pat/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
