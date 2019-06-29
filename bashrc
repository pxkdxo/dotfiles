## ~/.bashrc: executed by bash(1) for non-login shells


## If this is not an interactive shell, stop
[[ $- == *i* ]] || return 0

## Make a cache directory for bash user data
mkdir -m 0700 -p "${XDG_CACHE_HOME:-${HOME-}/.cache}/bash"




## -- Display --

## Check window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

## Send SIGWINCH to the current shell to initialize LINES and COLUMNS
kill -WINCH "$$"




## -- Shell Options --

## Traps on ERR will be inherited by functions, cmd subs, and subshells
set -o errtrace

## The >| operator is required to overwrite existing files via redirection
set -o noclobber

## The status of a terminated background job will be reported immediately
set -o notify




## -- Bash Options --

## If a directory name is given as a command, pass it to cd as an argument
shopt -s autocd

## Check if a command found in the hash table exists before trying to execute it
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




## -- Globbing Options --

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




## -- History Options --

## Configure the location of the history file
if [[ -d ${XDG_CACHE_HOME:-${HOME-}/.cache}/bash ]]; then
  HISTFILE="${XDG_CACHE_HOME:-${HOME-}/.cache}/bash/history"
fi

## Number of entries that may be kept in memory
HISTSIZE=10000

## Number of entries that may be kept on disk
HISTFILESIZE=10000

## Keep duplicates out of the command history
HISTCONTROL='erasedups'

## Ignore blanks surrounding otherwise immediate duplicates
HISTIGNORE='*([[:blank:]])&*([[:blank:]])'

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




## -- Prompt Appearance --

## Limit depth of paths produced from '\w' upon prompt expansion
PROMPT_DIRTRIM=4

## Create a table to hold terminfo data
declare -A ti=( )

## Set color_prompt to null to disable (enabled by default)
if [[ -n ${color_prompt-yes} ]] && tput setaf 1>/dev/null 2>&1; then
  color_prompt=yes
else
  color_prompt=
fi




## -- Prompt Strings --

## Set the primary prompt
__set_PS1() {
  PS1='\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
$(eval "printf %.s'$'\u2500'' {1..$(( ${COLUMNS-$(tput cols)} ))}")\
\[${ti[sgr0]:=$(tput sgr0)}\]\n\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\u\[${ti[dim]:=$(tput dim)}\]@\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\h\[${ti[dim]:=$(tput dim)}\]:\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\w\
\[${ti[sgr0]:=$(tput sgr0)}\]\n\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\[${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\$>\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}

## Set the secondary prompt
__set_PS2() {
  PS2='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') / 10 ))\
$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') % 10 ))\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}

## Set the select prompt
__set_PS3() {
  PS3='?> '
}

## Set the execution-trace prompt
__set_PS4() {
  PS4='.> '
}

## Update the prompt strings
__set_prompt_strings() {

  local status="${1:-$?}"
  local color=""

  if [[ -n ${color_prompt} ]] && (( status > 0 )); then
    color="$(tput setaf "$(( (status - 1) % 6 + 1 ))")"
  fi

  __set_PS1 "${color}"
  __set_PS2 "${color}"
  __set_PS3 "${color}"
  __set_PS4 "${color}"

  return "${status}"
}




## -- prompt_command / bash-preexec --

## Regex to check for presence of bash-preexec by matching its DEBUG trap
__bp_debug_trap_regex=\
$'trap -- \'(.*[;\n])?\\s*__bp_preexec_invoke_exec\\s*([;\n].*)?\' DEBUG'

## Check if bash-preexec is active
if [[ $(trap -p DEBUG) =~ ${__bp_debug_trap_regex} ]]; then

  ## Prepend function to update prompt strings to precmd_functions
  ( IFS=':'; [[ ":${precmd_functions[*]}:" != *:__set_prompt_strings:* ]] ) &&
    precmd_functions+=( __set_prompt_strings )

## If bash-preexec is not active...
else

  ## Setup prompt command
  [[ -n ${__prompt_command_loaded} ]] || {

    ## Prevent accidental re-configuration
    __prompt_command_loaded=yes

    ## Store the last exit status
    __last_status=""

    ## Set exit status to first arg
    __set_status() {
      return "$(( $1 ))"
    }

    ## Run the functions listed in prompt_command_functions
    __prompt_command() {
      __last_status=$?
      local function
      for function in "${prompt_command_functions[@]}"; do
        __set_status "$(( __last_status ))"
        "${function}"
      done
      return "$(( __last_status ))"
    }

    ## Create a list of functions to run in __prompt_command
    prompt_command_functions=( )

    ## Remove any traces of bash-preexec
    PROMPT_COMMAND="${PROMPT_COMMAND//*([[:blank:]])__bp_@(precmd_invoke_cmd|interactive_mode)?(;|$'\n')}"
    PROMPT_COMMAND="${PROMPT_COMMAND//__bp_last_ret_value/__last_status}"
    PROMPT_COMMAND="${PROMPT_COMMAND##*([[:space:]]|;)}"
    PROMPT_COMMAND="${PROMPT_COMMAND%%*([[:space:]]|;)}"
    PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND};}"

    ## Run prompt_command_functions before each primary prompt
    PROMPT_COMMAND="__prompt_command;${PROMPT_COMMAND:+ ${PROMPT_COMMAND}}"
  }

  ( IFS=':'; [[ ":${prompt_command[*]}:" != *:__set_prompt_strings:* ]] ) &&
    prompt_command_functions+=( __set_prompt_strings )
fi




## -- Window Titles ---

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
  (IFS=':'; [[ ":${precmd_functions[*]}:" != *:__set_window_title:* ]]) &&
    precmd_functions+=( __set_window_title )

elif [[ -n ${__prompt_command_loaded} ]]; then
  (IFS=':'; [[ ":${prompt_command[*]}:" != *:__set_window_title:* ]]) &&
    prompt_command_functions+=( __set_window_title )

else
  PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND%%?(;)*([[:blank:]])}; }__set_window_title;"

fi




## -- GnuPG --

## Set GPG_TTY to the TTY device on stdin
if tty --silent; then
  export GPG_TTY="$(tty)"
else
  export GPG_TTY=""
fi

## Refresh gpg-agent in case the user switched to an Xsession
gpg-connect-agent updatestartuptty /bye &>/dev/null

## Configure SSH to use gpg-agent instead of ssh-agent
if [[ ${SSH_AGENT_AUTH_SOCK-} != */S.gpg-agent.ssh ]]; then
  unset -v SSH_AGENT_PID
  if [[ ${gnupg_SSH_AUTH_SOCK_by:-0} -ne $$ ]]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
fi




## -- Lessopen --

## Make less more friendly for non-text input files
if command -v lesspipe 1>/dev/null; then
  eval "$(SHELL="$(command -v "${0##?(*/)?(-)}")" lesspipe)"
fi




## -- Bash Completion --

## Use bash-completion, if available, unless posix mode is set
if ! shopt -qo posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  fi
fi




## -- Bash Aliases --

## Check for bash_aliases file
if [[ -f ~/.bash_aliases ]]; then
  source ~/.bash_aliases
fi




## -- Extra Config --

## Recursively sources the contents of a directory
## Accepts a single set of arguments to pass to sourced scripts
sourcedir() {
  ## If this is the top layer of recursion, check status of nullglob
  if [[ "${FUNCNAME[0]}" != "${FUNCNAME[1]}" ]]; then
    local -i nullglob=0
    shopt -q nullglob && nullglob=1
  fi
  ## If the first arg is a directory, operate on its contents
  if [[ -d "$1"/ ]]; then
    ## Enable nullglob to allow empty expansions
    shopt -s nullglob
    ## Recurse through all files and subdirectoriess
    for _ in "$1"/*; do
      "${FUNCNAME[0]}" "$_" "${@:2}"
    done
    ## Disable nullglob for stability
    shopt -q nullglob && shopt -u nullglob
  ## If the first arg is not a directory, try to source it
  else
    ## Disable nullglob for stability
    shopt -q nullglob && shopt -u nullglob
    ## Source the first arg, passing in any additional params
    builtin source "$@"
  fi
  ## If this is the top layer of recursion, reset nullglob
  if [[ "${FUNCNAME[0]}" != "${FUNCNAME[1]}" ]]; then
    (( nullglob )) && shopt -s nullglob
  fi
  return 0
}




## Source addition config files
if [[ -d ~/.bashrc.d ]]; then
  sourcedir ~/.bashrc.d/
fi
