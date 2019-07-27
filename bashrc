#!/usr/bin/env bash
#
## ~/.bashrc: executed by bash(1) for non-login shells
###

## If this is not an interactive shell, stop
[[ $- == *i* ]] || return 0

## Make a cache directory for bash user data
mkdir -m 0700 -p "${XDG_CACHE_HOME:-${HOME-}/.cache}/bash"



## -- Display 

## Check window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

## Send SIGWINCH to the current shell to initialize LINES and COLUMNS
kill -WINCH "$$"



## -- Shell Options 

## Inherit ERR traps in functions, command substitutions, and subshells
set -o errtrace

## Require >| redirection operator to overwrite existing files
set -o noclobber

## Report the status of a terminated background job immediately
set -o notify

## Do not resolve symbolic links when executing builtins (such as cd)
set -o physical



## -- Bash Options 

## If a directory name is given as a command, pass it to cd as an argument
shopt -s autocd

## Confirm commands in the hash table exist before trying to execute them
shopt -s checkhash

## Show jobs before exiting and require confirmation if any are running
shopt -s checkjobs

## Expand directory names upon performing filename completion
shopt -s direxpand

## Attempt to correct mispelled directory names during word completion
shopt -s dirspell

## Send SIGHUP to all jobs when an interactive login shell exits
shopt -s huponexit

## Command substitutions inherit the value of the 'errexit' shell option
#shopt -s inherit_errexit

## If job control is off, run the last cmd of a pipeline in the current shell
#shopt -s lastpipe

## Enable programmable completion facilities
shopt -s progcomp



## -- Globbing Options 

## Ignore current locale's collating sequence when matching range-expressions
shopt -s globasciiranges

## Enable extended pattern matching features
shopt -s extglob

## ``**'' matches all files and zero or more directories and subdirectories
shopt -s globstar

## Ignore any shared object libraries found while searching for executables
EXECIGNORE='?(/usr?(/local))/lib?(?(x)@(32|64))/**/*.so*(.+([[:digit:]]))'

## Never match paths ending with an instance of ``.'' or ``..''
GLOBIGNORE='*(?(.)*/).?(.)*(/)'

## Assigning GLOBIGNORE sets 'dotglob' so unset it for standard behavior
shopt -u dotglob



## -- History Options 

## Configure the location of the history file
if [[ -d ${XDG_CACHE_HOME:-${HOME-}/.cache}/bash ]]; then
  HISTFILE="${XDG_CACHE_HOME:-${HOME-}/.cache}/bash/history"
fi

## Number of entries that may be kept in memory
HISTSIZE=10000

## Number of entries that may be kept on disk
HISTFILESIZE=10000

## Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'

## Ignore blanks surrounding otherwise immediate duplicates
HISTIGNORE='*([[:blank:]])@(&|fg|bg)*([[:blank:]])'

## Append to the history file instead of overwriting it
shopt -s histappend

## Attempt to save multiline commands as single entries
shopt -s cmdhist

## If 'cmdhist' is enabled, save multiline commands with embedded newlines
shopt -s lithist

## While using readline, load failed history subs into buffer for editing
shopt -s histreedit

## While using readline, load history sub results into buffer for editing
shopt -s histverify



## -- Prompting

## Limit depth of paths produced from '\w' upon prompt expansion
PROMPT_DIRTRIM=3

## Create a table to hold terminfo data
declare -A ti=( )

## Set color_prompt to null to disable (enabled by default)
if (( ${color_prompt-1} )) && tput setaf &>/dev/null; then
  color_prompt=1
else
  color_prompt=0
fi


## Set the primary prompt
__set_PS1()
{
  PS1='\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\[${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
$(while ((COLUMNS -= 1, COLUMNS > -1)); do printf '$'\u2500''; done)\
\[${ti[sgr0]:=$(tput sgr0)}\]\n\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\u\
\[${ti[dim]:=$(tput dim)}\]@\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\h\
\[${ti[dim]:=$(tput dim)}\]:\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\w\
\[${ti[sgr0]:=$(tput sgr0)}\]\n\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
\$>\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}


## Set the secondary prompt
__set_PS2()
{
  PS2='\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') / 10 ))\
$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') % 10 ))\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}


## Set the select prompt
__set_PS3()
{
  PS3='?: '
}


## Set the execution-trace prompt
__set_PS4()
{
  PS4='.\
${ti[sgr0]:=$(tput sgr0)}\
${ti[bold]:=$(tput bold)}\
>\
${ti[sgr0]:=$(tput sgr0)} '
}


## Set the pre-execution prompt
__set_PS0()
{
  PS0=${PS0}
}


## Update the prompt strings
__set_PS()
{
  case "$(( ${1:-$?} && ${color_prompt-0} ))" in
    0 ) set -- "${1:-$?}"
      ;;
    1 ) set -- "${1:-$?}" "$(tput setaf "$(( (${1:-$?} - 1) % 6 + 1 ))")"
      ;;
  esac

  __set_PS0 "$2"
  __set_PS1 "$2"
  __set_PS2 "$2"
  __set_PS3 "$2"
  __set_PS4 "$2"

  return "$(( $1 ))"
}



## -- PROMPT_COMMAND / bash-preexec 

## Regex to check for presence of bash-preexec by matching its DEBUG trap
__bp_debug_trap_regex=\
$'trap -- \'(.*[;\n])?\\s*__bp_preexec_invoke_exec\\s*([;\n].*)?\' DEBUG'

## Check if bash-preexec is active
if [[ $(trap -p DEBUG) =~ ${__bp_debug_trap_regex} ]]; then

  ## Remove any remains of prompt_command
  PROMPT_COMMAND=\
${PROMPT_COMMAND//*([[:blank:]])__prompt_command*([[:blank:]])?($'\n'|;)}
    PROMPT_COMMAND=\
${PROMPT_COMMAND//__prompt_command_last_status/__bp_last_ret_value}

  ## Prepend function to update prompt strings to precmd_functions
  ( IFS=':' &&
    [[ ":${precmd_functions[*]}:" != *:__set_PS:* ]] ) &&
    precmd_functions+=( __set_PS )

else
  ## Setup prompt command
  if (( !__prompt_command_loaded )); then

    ## Refresh (compact?) prompt command functions array
    __prompt_command_functions=( )

    ## Protection against accidental reloading
    __prompt_command_loaded=1

    ## Remove any remains of bash-preexec
    PROMPT_COMMAND=\
${PROMPT_COMMAND//*([[:blank:]])__bp_interactive_mode*([[:blank:]])?($'\n'|;)}
    PROMPT_COMMAND=\
${PROMPT_COMMAND//*([[:blank:]])__bp_precmd_invoke_cmd*([[:blank:]])?($'\n'|;)}
    PROMPT_COMMAND=\
${PROMPT_COMMAND//__bp_last_ret_value/__prompt_command_last_status}

    ## Trim leading and trailing w/s & semicolons
    PROMPT_COMMAND="${PROMPT_COMMAND##*([[:space:];])}"
    PROMPT_COMMAND="${PROMPT_COMMAND%%*([[:space:];])}"

    ## Run items in __prompt_command_functions before each primary prompt
    PROMPT_COMMAND="__prompt_command;${PROMPT_COMMAND:+ ${PROMPT_COMMAND};}"
  fi

  ## The exit status of the last command
  __prompt_command_last_status=0

  ## Set the exit status
  __prompt_command_set_status() {
    return "$(( $1 ))"
  }

  ## Run the functions from the prompt command functions array
  __prompt_command() {
    __prompt_command_last_status=$?
    local prompt_command_function
    __prompt_command_functions=( "${__prompt_command_functions[@]}" )
    for prompt_command_function in "${__prompt_command_functions[@]}"; do
      if command -v "${prompt_command_function}" 1>/dev/null; then
        __prompt_command_set_status __prompt_command_last_status
        "${prompt_command_function}"
      fi
    done
    return "$(( __prompt_command_last_status ))"
  }

  ## Append function to set prompt strings if not already included
  ( IFS=':' &&
    [[ :${__prompt_command_functions[*]}: != *:__set_PS:* ]]
  ) && __prompt_command_functions+=( __set_PS )

fi



## -- Window Titles -

## Configure terminal window titles
case ${TERM} in
  xterm*|rxvt*|vte*)
    __set_window_title() {
      printf '\e]0;%s@%s:%s\a' "${USER}" "${HOSTNAME%%.*}" "${PWD/#"$HOME"/\~}"
      #
    }
    ;;
  screen*|tmux*)
    __set_window_title() {
      printf '\ek%s@%s:%s\e\' "${USER}" "${HOSTNAME%%.*}" "${PWD/#"$HOME"/\~}"
    }
    ;;
  *)
    __set_window_title() {
      return 0
    }
    ;;
esac

if [[ $(trap -p DEBUG) =~ ${__bp_debug_trap_regex} ]]; then
  ( IFS=':' &&
    [[ ":${precmd_functions[*]}:" != *:__set_window_title:* ]]
  ) && precmd_functions+=( __set_window_title )

elif [[ -n ${__prompt_command_loaded} ]]; then
  ( IFS=':' &&
    [[ ":${__prompt_command_functions[*]}:" != *:__set_window_title:* ]]
  ) && __prompt_command_functions+=( __set_window_title )
fi



## -- GnuPG 

## Set GPG_TTY to the TTY device on stdin
tty --silent && GPG_TTY=$(tty) || GPG_TTY=""
export GPG_TTY

## Refresh gpg-agent in case the user switched to an Xsession
gpg-connect-agent updatestartuptty /bye &>/dev/null

## Configure SSH to use gpg-agent instead of ssh-agent
if ! [[ -S ${SSH_AUTH_SOCK} && ${SSH_AUTH_SOCK} == */S.gpg-agent.ssh ]]; then
  unset -v SSH_AGENT_PID
  if (( ${gnupg_SSH_AUTH_SOCK_by:-0} != $$ )); then
    SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    export SSH_AUTH_SOCK
  fi
fi



## -- Lessopen 

## Make less more friendly for non-text input files
if command -v lesspipe 1>/dev/null; then
  eval "$(SHELL=${BASH:-$(command -v bash)} lesspipe)"
fi



## -- Bash Completion 

## Load bash-completion, if available, unless posix mode is set
shopt -qo posix ||
  if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  fi



## -- Bash Aliases 

## Check for bash_aliases file
if [[ -f ~/.bash_aliases ]]; then
  source ~/.bash_aliases
fi



## -- Extra Config 

## Recursively source the contents of a directory
sourcedir()
{
  if [[ -d $1/ ]]; then
    for _ in "${1%"${1##*[^/]}"}"/*; do
      "${FUNCNAME}" "$_" "${@:2}"
    done
  else
    builtin source "$@"
  fi
}



## Run additional startup scripts
if [[ -d ~/.bashrc.d/ ]]; then
  sourcedir ~/.bashrc.d/
fi
