# ~/.bashrc: executed by bash(1) for non-login shells
# see bash(1)
# see examples in /usr/doc/bash/examples/startup-files (from package bash-doc


## -- Initialization --

# If this is not an interactive shell, stop
[[ $- != *i* ]] && return 0

# Create a cache directory
mkdir -p -m 0700 "${XDG_CACHE_HOME:-"${HOME}/.cache"}/bash"

# Make an associative array to store terminfo entries
declare -A ti=( )




## -- Display --

# Send SIGWINCH to the current shell to initialize LINES and COLUMNS
kill -s SIGWINCH "$$" 2>/dev/null

# If DISPLAY is non-null, update LINES and COLUMNS after each command
[[ -n ${DISPLAY} ]] && shopt -s checkwinsize




## -- Shell Options --

# Traps on ERR will be inherited by functions, cmd subs, and subshells
set -o errtrace

# The >| operator is required to overwrite existing files via redirection
set -o noclobber

# The status of a terminated background job will be reported immediately
set -o notify




## -- Bash Options --

# If the name of a directory is given as a command, pass it to 'cd'
shopt -s autocd

# Check that commands found in the hashtable exist before running them
shopt -s checkhash

# Show jobs before exiting shell and require confirmation if any are running
shopt -s checkjobs

# Expand the name of a directory upon performing filename completion
shopt -s direxpand

# Attempt to correct mispelled directory names during word completion
shopt -s dirspell

# Send SIGHUP(1) to all jobs when an interactive login shell exits
shopt -s huponexit

# Command substitutions inherit the value of the 'errexit' shell option
shopt -s inherit_errexit

# If job control is off, run the last cmd of a pipeline in the current shell
shopt -s lastpipe




## -- Globbing Options --

# Use C locale when matching range-expressions
shopt -s globasciiranges

# Enable extended pattern matching features
shopt -s extglob

# Let ``**`` match all files and 0 or more directories and subdirectories
shopt -s globstar

# Ignore shared object libraries when searching for executables
EXECIGNORE='/**/lib?(32|64)/**/*.@(dll|so*(.+([[:digit:]])))'

# Ignore paths ending with an instance of ``.'' or ``..''
GLOBIGNORE='*(?(.)*/).?(.)*(/)'

# Assigning GLOBIGNORE sets 'dotglob' so unset it for standard behavior
shopt -u dotglob




## -- History Options --

# Configure the location of the history file
if [[ -d ${XDG_CACHE_HOME:-${HOME}/.cache}/bash ]]; then
  HISTFILE="${XDG_CACHE_HOME:-"${HOME}/.cache"}/bash/history"
else
  HISTFILE="${HOME}/.bash_history"
fi

# Number of entries that may be kept in memory
HISTSIZE=10000

# Number of entries that may be kept on disk
HISTFILESIZE=10000

# Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'

# Ignore blanks surrounding otherwise immediate duplicates
HISTIGNORE='*([[:blank:]])&*([[:blank:]])'

# Attempt to save multiline commands as single entries
shopt -s cmdhist

# Append to the history file instead of overwriting it
shopt -s histappend

# If using readline, allow user to re-edit a failed history substitution
shopt -s histreedit

# If using readline, load history substitutions into the editing buffer
shopt -s histverify

# With 'cmdhist' enabled, save multiline commands with embedded newlines
shopt -s lithist




## -- Prompt Appearance --

# Limit depth of paths yielded by '\w' upon prompt exanding
declare -i PROMPT_DIRTRIM=4

# Uncomment for a colored prompt (assuming terminal has the capability)
color_prompt='yes'

# If color_prompt is non-null, check for color support
[[ -n ${color_prompt} ]] && {
  { command -v tput && tput setaf 2>&1; } 1>/dev/null ||
    unset -v color_prompt
}




## -- Prompt Strings --

# Sets the primary prompt
PS1() {
  declare -g PS1='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
$(printf '\''%.s'$'\u2500'\'' {1..'"$(( COLUMNS ? COLUMNS : "$(tput cols)" ))"'}
)\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\n\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\u\
\[${ti[dim]:=$(tput dim)}\]\
@\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\h\
\[${ti[dim]:=$(tput dim)}\]\
:\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\w\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\n\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\D{%A %d %B %Y %I:%M %p %Z}\
\[${ti[sgr0]:=$(tput sgr0)}\]\
\n\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
\$>\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}


# Sets the secondary prompt
PS2() {
  declare -g PS2='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
$(( (LINENO - '"$((BASH_LINENO[-1]))"') / 10 ))\
$(( (LINENO - '"$((BASH_LINENO[-1]))"') % 10 ))\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}


# Sets the select prompt
PS3() { declare -g PS3='?> '; }


# Sets the execution-trace prompt
PS4() { declare -g PS4='.> '; }


# Updates the prompt strings
__set_prompt_strings() {

  # If called with no args, set 1st param to exit status of previous command
  set -- "${1:-"$?"}"

  # If color_prompt is non-null, set prompt color based on value of 1st param
  if [[ -n ${color_prompt} ]] && (( $1 > 0 )); then
    set -- "$1" "$(tput setaf "$(( ($1 - 1) % 6 + 1 ))")"
  fi

  PS1 "$2"  # Set primary prompt
  PS2 "$2"  # Set secondary prompt
  PS3 "$2"  # Set select-loop prompt
  PS4 "$2"  # Set exec-trace prompt

  # Return exit status of the last command executed before this function
  return "$1"
}




## -- PROMPT_COMMAND / bash-preexec --

# Regex to check for presence of bash-preexec by matching its DEBUG trap
__bp_debug_trap_regex=\
"trap -- '(.*[;"$'\n''])?\s*__bp_preexec_invoke_exec\s*([;'$'\n'"].*)?' DEBUG"

# Check if bash-preexec is active
if [[ $(trap -p DEBUG) =~ ${__bp_debug_trap_regex} ]]; then

  # Prepend function to update prompt strings to precmd_functions
  precmd_functions=( __set_prompt_strings "${precmd_functions[@]}" )

# Check if the prompt_command array is configured
elif [[ ${prompt_command} != __set_prompt_strings ]]; then

  # Check if the prompt_command array needs to be created
  if [[ ${prompt_command@a} != *a* ]]; then

    # Unset any existing prompt_command variable
    [[ -v prompt_command ]] && unset -v prompt_command

    # Read commands from PROMPT_COMMAND into the prompt_command array
    IFS=$';\n' read -r -d '' -a prompt_command <<<"${PROMPT_COMMAND}"

    # Execute the commands in prompt_command before each primary prompt
    PROMPT_COMMAND='for _ in "${prompt_command[@]}"; do eval "$_"; done'
  fi

  # Prepend function to update the prompt strings to prompt_command
  prompt_command=( __set_prompt_strings "${prompt_command[@]}" ) 

fi




## -- Window Titles ---

# Configure terminal window titles
case ${TERM} in

  xterm*|rxvt*|vte*)
    # Sets the window title (Using eval to avoid a syntax highlighting bug)
    eval '__set_window_title() {
      printf "\e]0;%s@%s:%s\a" "${USER}" "${HOSTNAME%%.*}" "${PWD/#"${HOME}"/\~}"
    }'
    ;;&

  screen*|tmux*)
    # Sets the window title (Using eval to avoid a syntax highlighting bug)
    eval '__set_window_title() {
      printf "\ek%s@%s:%s\e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#"${HOME}"/\~}"
    }'
    ;;&

  xterm*|rxvt*|vte*|screen*|tmux*)
    # Test for bash-preexec
    if [[ $(trap -p DEBUG) =~ ${__bp_debug_trap_regex} ]]; then
      ( IFS=':'; [[ ":${precmd_functions[*]}:" != *:__set_window_title:* ]] ) &&
        precmd_functions+=( __set_window_title )
    else
      ( IFS=':'; [[ ":${prompt_command[*]}:" != *:__set_window_title:* ]] ) &&
        prompt_command+=( __set_window_title )
    fi
    ;;

esac




## -- Bash Completion --

# Looks for bash-completion in XDG directories, falling back to sane defaults
# Sources first file found
__load_bash_completion() {
  if local IFS=':' && local -a dirs=( 
    "${XDG_DATA_HOME:-"${HOME-}/.local/share"}"
    "${XDG_DATA_DIRS:-"/usr/local/share:/usr/share"}"
    )
  then
    read -r -a dirs <<<"${dirs[*]}"
    for _ in "${dirs[@]}"; do
      if [[ -f "$_/bash-completion/bash_completion" ]]; then
        if source "$_/bash-completion/bash_completion"; then
          return 0
        fi
      fi
    done
  fi
  return 1
}


# Load bash completions unless posix mode if off
shopt -oq posix || __load_bash_completion || {
  [[ -f /etc/bash_completion ]] && source /etc/bash_completion
}




## -- GnuPG --

# Set GPG_TTY to the tty device on stdin & add it to the environment
if tty --silent; then
  export GPG_TTY="$(tty)"
else
  export GPG_TTY=''
fi

# Refresh gpg-agent in case the user switched to an Xsession
gpg-connect-agent updatestartuptty /bye 1>/dev/null 2>&1

## Configure SSH to use gpg-agent
[[ -S ${SSH_AUTH_SOCK} && ${SSH_AUTH_SOCK} == /?(*/)S.gpg-agent.ssh ]] || {
  unset -v SSH_AGENT_PID
  ## Check that gpg-agent was not started as 'gpg-agent --daemon /bin/sh'
  if (( ${gnupg_SSH_AUTH_SOCK_by:-0} != $$ )); then
    ## Set SSH_AUTH_SOCK to gpg-agent's socket and add it to the environment
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
}




## -- Lessopen --

# Make less more friendly for non-text input files
command -v lesspipe 1>/dev/null &&
  eval "$(SHELL="$(command -v "${0##*(*/|-)}")" lesspipe)"




## -- Extra Config --

# Recursively sources the contents of a directory
# Accepts a single set of arguments to pass on to sourced scripts
sourcedir() {

  # If this is the top layer of recursion, check status of nullglob
  [[ "${FUNCNAME[0]}" == "${FUNCNAME[1]}" ]] || {
    local -i nullglob=0
    shopt -q nullglob && nullglob=1
  }

  # If the first arg is a directory, operate on its contents
  if [[ -d "$1"/ ]]; then

    # Enable nullglob to allow empty expansions
    shopt -s nullglob

    # Recurse through all files and subdirectoriess
    for _ in "$1"/*; do
      "${FUNCNAME[0]}" "$_" "${@:2}"
    done

    # Disable nullglob for stability
    shopt -q nullglob && shopt -u nullglob

  # If the first arg is not a directory, try to source it
  else

    # Disable nullglob for stability
    shopt -q nullglob && shopt -u nullglob

    # Source the first arg, passing in any additional params
    builtin source "$@"

  fi

  # If this is the top layer of recursion, reset nullglob
  [[ "${FUNCNAME[0]}" == "${FUNCNAME[1]}" ]] || {
    (( nullglob )) && shopt -s nullglob
  }

  return 0
}


# Source addition config files
sourcedir ~/.bashrc.d




# vi:et:sts=2:sw=2:ts=8:tw=80
