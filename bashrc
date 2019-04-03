# ~/.bashrc: executed by bash(1) for non-login shells
# see bash(1)
# see examples in /usr/doc/bash/examples/startup-files (from package bash-doc


## -- Initialization --

# If this is not an interactive shell, stop
case $- in
  *i*) ;;
    *) return 0 ;;
esac


# Create a directory to store shell data files
mkdir -p "${XDG_CACHE_HOME:-"${HOME}/.cache"}/bash"


# Make an associative array to store terminfo entries
declare -A ti=()



## -- Display --

# Send SIGWINCH to the current shell to initialize LINES and COLUMNS
kill -s WINCH "$$" 2>/dev/null

# If DISPLAY is non-null, update LINES and COLUMNS after each command
test -n "${DISPLAY}" && shopt -s checkwinsize



## -- GnuPG --

# Set GPG_TTY to the tty device on stdin
if tty --silent; then
  GPG_TTY="$(tty)"
else
  GPG_TTY=""
fi

# Add GPG_TTY to the environment
export GPG_TTY

# Refresh gpg-agent (in case user switched to an Xsession)
if command -v gpg-connect-agent; then
  gpg-connect-agent updatestartuptty /bye
fi 1>/dev/null 2>&1



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



## -- History Options --

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

# Number of entries that may be kept in memory
HISTSIZE=10000

# Number of entries that may be kept on disk
HISTFILESIZE=10000

# Configure the location of the history file
HISTFILE="${XDG_CACHE_HOME:-"${HOME}/.cache"}/bash/history"

# Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'

# Disregard additional blanks around immediate duplicates
HISTIGNORE='*([[:blank:]])&*([[:blank:]])'



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

# Assigning GLOBIGNORE sets 'dotglob' so unset it to get standard behavior
shopt -u dotglob



## -- Prompt Strings --

# Function to set the primary prompt
PS1() { declare -g PS1='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
$(printf '"'"'%.s─'"'"' {1..'"$(( COLUMNS ? COLUMNS : "$(tput cols)" ))"'}
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
\$'$'\u0192\u2022''\
\[${ti[sgr0]:=$(tput sgr0)}\] '; }


# Function to set the secondary prompt
PS2() { declare -g PS2='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
$(( (LINENO - '"$((BASH_LINENO[-1]))"') / 10 ))\
$(( (LINENO - '"$((BASH_LINENO[-1]))"') % 10 ))\
'$'\u2022''\
\[${ti[sgr0]:=$(tput sgr0)}\] '; }


# Function to set the select prompt
PS3() { declare -g PS3=$'?\u2022 '; }


# Function to set the execution-trace prompt
PS4() { declare -g PS4='+\
\[${ti[sgr0]:=$(tput sgr0)}\]\
'$'\u2022''\
\[${ti[sgr0]:=$(tput sgr0)}\] '; }



## -- Prompt Appearance --

# Limit depth of paths yielded by '\w' upon prompt exanding
PROMPT_DIRTRIM=4


# uncomment for a colored prompt, if the terminal has the capability
color_prompt='yes'

if test -n "${color_prompt}"; then

  if command -v tput && tput setaf 1; then
    # We have color support; assume it's compliant with Ecma-48 (ISO/IEC-6429)
    color_prompt='yes'

  else
    # No color support
    color_prompt=''

  fi 1>/dev/null
fi


# Function to update the prompt strings
SetPS() {

  # Get exit status of previous command
  set -- "$?"

  # Set a color based on given STATUS (if 'color_prompt' is non-null)
  if test -n "${color_prompt}" && test "$(($1))" -gt 0; then
    local PS_color="$(tput setaf "$(( ($(($1)) - 1) % 6 + 1 ))")"
  else
    local PS_color=''
  fi

  PS1 "${PS_color}"  # Set primary prompt
  PS2 "${PS_color}"  # Set secondary prompt
  PS3 "${PS_color}"  # Set select-loop prompt
  PS4 "${PS_color}"  # Set exec-trace prompt

  return "$(($1))"   # Returns the STATUS given as an argument
}



## -- Prompt --

## Test for bash-preexec
if [[ "$(trap -p DEBUG)" == 'trap -- '"'"?(*@(;|$'\n'))*([[:space:]])__bp_preexec_invoke_exec*([[:space:]])?(@(;|$'\n')*)"'" ]]; then

  ## Add Pre-Cmd function
  precmd_functions=( 'SetPS' "${precmd_functions[@]}" )

else
  # Declare an array to store a list of commands to execute from PROMPT_COMMAND
  prompt_command=( )

  # Execute each command in ``prompt_command'' before printing a primary prompt
  PROMPT_COMMAND='for _ in "${prompt_command[@]}"; do eval "$_"; done'

  # Set prompt_command to update the strings before each primary prompt
  prompt_command=( 'SetPS "$?"' "${prompt_command[@]}" ) 
fi



## -- Window Title ---

case "${TERM}" in
  xterm*|rxvt*|vte*)
    prompt_command+=( 
  'printf "\e]0;%s@%s:%s\a" "${USER}" "${HOSTNAME%%.*}" "${PWD/#"${HOME}"/~}"'
)
    ;;
  screen*|tmux*)
    prompt_command+=( 
  'printf "\ek%s@%s:%s\e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#"${HOME}"/~}"'
)
    ;;
esac



## -- Bash Completion --

# Looks for bash-completion in XDG directories, falling back to sane defaults
# Note: only sources first file found
load_bash_completion() {
  local IFS=:
  for _ in ${XDG_DATA_HOME:-~/.local/share} ${XDG_DATA_DIRS:-/usr/share}; do
    if [[ -f "$_/bash-completion/bash_completion" ]]; then
      source "$_/bash-completion/bash_completion"
      return
    fi
  done
}

# Load bash_completion if available
if ! shopt -oq posix; then
  load_bash_completion
fi



# -- Lessopen --

# Make less more friendly for non-text input files
if command -v lesspipe 1> /dev/null; then
  eval "$(SHELL="$(command -v sh)" lesspipe)"
fi



## -- Extra Config --

# Recursively sources contents of a directory
# Note: only allows passing a single set of arguments
sourcer() {

  # Unset 'dotglob'
  if test "${FUNCNAME[0]}" != "${FUNCNAME[1]}"; then
    local -r BASHOPTS_local="${BASHOPTS}" &&
      shopt -u dotglob || 
      return "$?"
  fi

  # Operate on arguments
  if test -d "$1"/; then
    shopt -s nullglob
    for _ in "$1"/*; do
      "${FUNCNAME[0]}" "$_" "${@:2}"
    done
    shopt -q nullglob && shopt -u nullglob
  else
    shopt -q nullglob && shopt -u nullglob
    builtin source "$@"
  fi

  # Reset 'dotglob' and 'nullglob'
  if test "${FUNCNAME[0]}" != "${FUNCNAME[1]}"; then
    case ":${BASHOPTS_local}:" in
      *":dotglob:"*)  shopt -s dotglob  ;;&
      *":nullglob:"*) shopt -s nullglob ;;&
    esac
  fi

  return 0
}


# Source addition config files
sourcer ~/.bashrc.d




# vi:et:sts=2:sw=2:ts=8:tw=79
