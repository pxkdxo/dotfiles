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

# Number of entries that may be kept in memory
HISTSIZE=10000

# Number of entries that may be kept on disk
HISTFILESIZE=10000

# Configure the location of the history file
HISTFILE="${XDG_CACHE_HOME:-"${HOME}/.cache"}/bash/history"

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



## -- Prompt Appearance --

# Limit depth of paths yielded by '\w' upon prompt exanding
PROMPT_DIRTRIM=4

# Use colored prompt if the terminal has the capability
color_prompt="${color_prompt:-"yes"}"

# Check if color_prompt is enabled
[[ ${color_prompt^^} == @(Y?(ES)|T?(RUE)|ON|1) ]] && {
  # Check for color support; assume it's compliant with Ecma-48 (ISO/IEC-6429)
  { command -v tput 1>/dev/null && tput setaf 1; } || {
    # No color support
    color_prompt=''
  }
}



## -- Prompt Strings --

# Function to set the primary prompt
PS1() { declare -g PS1='\
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
PS3() { declare -g PS3='*> '; }


# Function to set the execution-trace prompt
PS4() { declare -g PS4='+> '; }



# Function to update the prompt strings
__set_prompt_strings() {

  # Get exit status of previous command
  set -- "$?"

  # Set a color based on previous exit status (if color_prompt is enabled)
  (( $1 > 0 )) && [[ ${color_prompt^^} == @(Y?(ES)|T?(RUE)|ON|1) ]] &&
    set -- "$1" "$(tput setaf "$(( ($1 - 1) % 6 + 1 ))")"

  PS1 "$2"  # Set primary prompt
  PS2 "$2"  # Set secondary prompt
  PS3 "$2"  # Set select-loop prompt
  PS4 "$2"  # Set exec-trace prompt

  return "$1"   # Return exit status from the command before this function
}




## -- Prompt --

#if [[ "$(trap -p DEBUG)" == 'trap -- '"'"?(*@(;|$'\n'))*([[:space:]])__bp_preexec_invoke_exec*([[:space:]])?(@(;|$'\n')*)"'"' DEBUG' ]]; then

# Regular expression to match bash-preexec's debug trap
__bash_preexec_regex=\
"trap -- '(.*[;"$'\n''])?\s*__bp_preexec_invoke_exec\s*([;'$'\n'"].*)?' DEBUG"

## Test for bash-preexec
if [[ "$(trap -p DEBUG)" =~ ${__bash_preexec_regex} ]]; then

  ## Add Pre-Cmd function
  precmd_functions=( '__set_prompt_strings' "${precmd_functions[@]}" )

## Check that the prompt_command array is not configured
elif [[ ${prompt_command[0]} != __set_prompt_strings ]]; then

  # Create array to store a list of commands to execute from PROMPT_COMMAND
  if [[ ${prompt_command@a} != *a* ]]; then
    IFS=$';\n' read -r -d '' -a prompt_command <<<"${PROMPT_COMMAND}"
  fi

  # Execute each command in ``prompt_command'' before printing a primary prompt
  PROMPT_COMMAND='for _ in "${prompt_command[@]}"; do eval "$_"; done'

  # Set prompt_command to update the strings before each primary prompt
  prompt_command=( '__set_prompt_strings' "${prompt_command[@]}" ) 
fi




## -- Window Title ---

case ${TERM} in

  xterm*|rxvt*|vte*|iterm*|st*)
    # Sets the window title
    __set_window_title() {
      printf "\e]0;%s@%s:%s\a" "${USER}" "${HOSTNAME%%.*}" "${PWD/#${HOME}/\~}"
    }
    # Test for bash-preexec
    if [[ "$(trap -p DEBUG)" =~ ${__bash_preexec_regex} ]]; then
      if (
        IFS=':'
        [[ ":${precmd_functions[*]}:" != *:__set_window_title:* ]]
      ); then
        precmd_functions+=( "__set_window_title" )
      fi
    else
      if (
        IFS=':'
        [[ ":${prompt_command[*]}:" != *:__set_window_title:* ]]
      ); then
        prompt_command+=( "__set_window_title" )
      fi
    fi
    ;;

  screen*|tmux*)
    # Sets the window title
    __set_window_title() {
      printf "\ek%s@%s:%s\e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#${HOME}/\~}"
    }
    # Test for bash-preexec
    if [[ "$(trap -p DEBUG)" =~ ${__bash_preexec_regex} ]]; then
      if (
        IFS=':'
        [[ ":${precmd_functions[*]}:" != *:__set_window_title:* ]]
      ); then
        precmd_functions+=( "__set_window_title" )
      fi
    else
      if (
        IFS=':'
        [[ ":${prompt_command[*]}:" != *:__set_window_title:* ]]
      ); then
        prompt_command+=( "__set_window_title" )
      fi
    fi
    ;;

esac




## -- Bash Completion --

# Looks for bash-completion in XDG directories, falling back to sane defaults
# Note: only sources first file found
__load_bash_completion() {
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
  __load_bash_completion
fi




## -- Lessopen --

# Make less more friendly for non-text input files
if command -v lesspipe 1>/dev/null; then
  eval "$(SHELL="$(command -v sh)" lesspipe)"
fi




## -- Bash Traps --

## Array of all traps indexed by signal name
declare -A BASH_TRAPS=(
  [HUP]=''        [INT]=''        [QUIT]=''      
  [ILL]=''        [TRAP]=''       [ABRT]=''      
  [BUS]=''        [FPE]=''        [KILL]=''      
  [USR1]=''       [SEGV]=''       [USR2]=''              
  [PIPE]=''       [ALRM]=''       [TERM]=''      
  [STKFLT]=''     [CHLD]=''       [CONT]=''      
  [STOP]=''       [TSTP]=''       [TTIN]=''      
  [TTOU]=''       [URG]=''        [XCPU]=''              
  [XFSZ]=''       [VTALRM]=''     [PROF]=''      
  [WINCH]=''      [IO]=''         [PWR]=''       
  [SYS]=''        [RTMIN]=''      [RTMIN+1]=''   
  [RTMIN+2]=''    [RTMIN+3]=''    [RTMIN+4]=''           
  [RTMIN+5]=''    [RTMIN+6]=''    [RTMIN+7]=''   
  [RTMIN+8]=''    [RTMIN+9]=''    [RTMIN+10]=''  
  [RTMIN+11]=''   [RTMIN+12]=''   [RTMIN+13]=''  
  [RTMIN+14]=''   [RTMIN+15]=''   [RTMAX-14]=''          
  [RTMAX-13]=''   [RTMAX-12]=''   [RTMAX-11]=''  
  [RTMAX-10]=''   [RTMAX-9]=''    [RTMAX-8]=''   
  [RTMAX-7]=''    [RTMAX-6]=''    [RTMAX-5]=''   
  [RTMAX-4]=''    [RTMAX-3]=''    [RTMAX-2]=''   
  [RTMAX-1]=''    [RTMAX]=''      [DEBUG]=''        
  [ERR]=''        [EXIT]=''       [RETURN]=''               
)


# Maps traps to signal names
__update_bash_traps() {
  local -             &&
    set -o functrace  &&
    local sig=''      &&
    for sig in "${!BASH_TRAPS[@]}"; do
      declare -Ag BASH_TRAPS["${sig}"]="$(trap -p "${sig}")"
    done
  trap "${BASH_TRAPS["RETURN"]:-"trap RETURN"}" RETURN
} && declare -ft __update_bash_traps


## Test for bash-preexec
if [[ "$(trap -p DEBUG)" =~ ${__bash_preexec_regex} ]]; then
  
  if (
    IFS=':'
    [[ ":${precmd_functions[*]}:" != *:__update_bash_traps:* ]]
  ); then
    ## Add Pre-Cmd function to update BASH_TRAPS
    precmd_functions+=( '__update_bash_traps' )
  fi

else 
  if (
    IFS=':'
    [[ ":${prompt_command[*]}:" != *:__update_bash_traps:* ]]
  ); then
    ## Add prompt_command function to update BASH_TRAPS
    prompt_command+=( '__update_bash_traps' )
  fi

fi

  


## -- Extra Config --

# Recursively sources contents of a directory
# Note: only allows a single set of arguments to sourced scripts
sourcedir() {

  # Check if this is the top layer of recursion
  if [[ "${FUNCNAME}" != "${FUNCNAME[1]}" ]]; then
    # Save current BASHOPTS
    local BASHOPTS_local="${BASHOPTS}" || return "$?"
  fi

  # Check if first argument is a directory
  if [[ -d "$1"/ ]]; then
    # Enable nullglob to allow empty expansions
    shopt -s nullglob
    # Recurse on all files and subdirectories (if any)
    for _ in "$1"/*; do
      "${FUNCNAME}" "$_" "${@:2}"
    done
    # If nullglob is still enabled, disable it for stability
    shopt -q nullglob && shopt -u nullglob

  # If first argument is not a directory...
  else
    # If nullglob is still enabled, disable it for stability
    shopt -q nullglob && shopt -u nullglob
    # Source the first argument, passing any additional parameters
    builtin source "$@"
  fi

  # Check if this is the top layer of recursion
  if [[ "${FUNCNAME}" != "${FUNCNAME[1]}" ]]; then
    # Reset 'nullglob' to original state
    case ":${BASHOPTS_local}:" in
      *":nullglob:"*) shopt -s nullglob ;;&
    esac
  fi

  return 0

}


# Source addition config files
sourcedir ~/.bashrc.d




# vi:et:sts=2:sw=2:ts=8:tw=80
