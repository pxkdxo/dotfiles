## ~/.bashrc : bash interactive shell initialization file
 

## Is this really an interactive shell? If not, stop.
[[ $- != *i* ]] && return 0



## If DISPLAY is non-null, update LINES and COLUMNS after each command
[[ -n ${DISPLAY} ]] && shopt -s checkwinsize

## Send SIGWINCH to the current shell to initialize LINES and COLUMNS
kill -s 28 "$$" 2>/dev/null



{ ## Configure the environment for gpg-agent

  { ## Set GPG_TTY to the file connected to stdin
    wait "$!"  && read -r -d '' GPG_TTY || GPG_TTY=/dev/null

    ## Mark GPG_TTY for export to subsequent commands
    export GPG_TTY

  } < <(command -p realpath -qz "/proc/$$/fd/0")

  ## Refresh gpg-agent in case user switched to an Xsession
  command -p gpg-connect-agent updatestartuptty /bye

} 2>/dev/null



## Traps on ERR will be inherited by functions, cmd substs, and subshells
set -o errtrace

## The >| operator is required to overwrite existing files via redirection
set -o noclobber

## The status of a terminated background job will be reported immediately
set -o notify



## If the name of a directory is given as a command, pass it to cd
shopt -s autocd

## Check that a command found in the hashtable exists before running it
shopt -s checkhash

## Show jobs before exiting and require confirmation if any are running
shopt -s checkjobs

## Attempt to save each multiline command as a single history entry
shopt -s cmdhist

## Expand the name of a directory upon performing filename completion
shopt -s direxpand

## Attempt to correct mispelled directory names during word completion
shopt -s dirspell

## Enable extended pattern matching features
shopt -s extglob

## Let ``**`` match all files and 0 or more directories and subdirectories
shopt -s globstar

## Send SIGHUP(1) to all jobs when an interactive login shell exits
shopt -s huponexit

## Append to the history file instead of overwriting it
shopt -s histappend

## If using rl, allow user to re-edit a failed history substitution
shopt -s histreedit

## If using rl, load history substitutions into the editing buffer
shopt -s histverify

## Command substitutions inherit the value of the 'errexit' option
shopt -s inherit_errexit

## If job control is off, run the last cmd of a pipeline in the current shell
shopt -s lastpipe

## With 'cmdhist' enabled, save multiline commands with embedded newlines
shopt -s lithist



## Ignore shared object libraries when searching for executables
EXECIGNORE='/**/lib?(32|64)/**/*.@(dll|so*(.+([[:digit:]])))'

## Ignore paths ending at an instance of ``.'' or ``..''
GLOBIGNORE='*(?(.)*/).?(.)*(/)'

## Setting GLOBIGNORE enables 'dotglob' so disable it to go back to normal
shopt -u dotglob



## Configure the location of the history file
HISTFILE="${XDG_DATA_HOME:-"${HOME}/.local/share"}/bash/history"

## Number of entries that may be kept on disk
HISTFILESIZE=30000

## Number of entries that may be kept in memory
HISTSIZE=32767

## Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'

## Disregard additional blanks around immediate duplicates
HISTIGNORE='*([[:blank:]])&*([[:blank:]])'

## Limit the depth of paths produced from '\w' during prompt expansion
PROMPT_DIRTRIM=4



## Create a directory to store shell data
mkdir -p "${XDG_DATA_HOME:-"${HOME}/.local/share"}/bash"

## Make an associative array to store terminfo data
declare -A ti=( )



## Function to set the primary prompt
PS1() {
  PS1='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
$(printf '"'"'%.s─'"'"' {1..'"$(( $((COLUMNS))?$((COLUMNS)):$(tput cols) ))"'})\
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
\$√:\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}



## Function to set the secondary prompt
PS2() {
  PS2='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}\]\
\['"$1"'\]\
$(( (LINENO - '"$((BASH_LINENO[-1]))"') / 10 ))\
$(( (LINENO - '"$((BASH_LINENO[-1]))"') % 10 ))\
…\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}



## Function to set the select prompt
PS3() {
  PS3='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
*\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
◆\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
*\
\[${ti[sgr0]:=$(tput sgr0)}\] '
  PS3=${PS3@P}
}



## Function to set the execution-trace prompt
PS4() {
  PS4='\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
•\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
\['"$1"'\]\
◆\
\[${ti[sgr0]:=$(tput sgr0)}${ti[bold]:=$(tput bold)}${ti[dim]:=$(tput dim)}\]\
:\
\[${ti[sgr0]:=$(tput sgr0)}\] '
}



## Function to update the prompt strings 
SetPS() {

  local -

  set - "$([[ $1 -gt 0 ]] && tput setaf "$(( ($1 - 1) % 6 + 1 ))")"

  PS1 "$1"
  PS2 "$1"
  PS3 "$1"
  PS4 "$1"
}



## Execute each command in ``prompt_command'' before each primary prompt
declare -r PROMPT_COMMAND='for _ in "${prompt_command[@]}"; do eval "$_"; done'
declare -a prompt_command=( )

## Update prompt strings
prompt_command[0]='SetPS "$?"'

## Update window titles
case ${TERM} in
  xterm*|vte*)
    prompt_command+=( 
  'printf "\e]0;%s@%s:%s\a" "${USER}" "${HOSTNAME%%.*}}" "${PWD/#"${HOME}"/\~}"'
)
    ;;
  screen*|tmux*)
    prompt_command+=( 
  'printf "\ek%s@%s:%s\e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#"${HOME}"/\~}"'
)
    ;;
esac



## Looks for bash-completion in XDG directories, falling back to sane defaults
load_bash_completion() {
  local IFS=':'
  for _ in ${XDG_DATA_HOME:-~/.local/share} ${XDG_DATA_DIRS:-/usr/share}; do
    [[ -f $_/bash-completion/bash_completion
    && -r $_/bash-completion/bash_completion
    ]] && {
      source "$_/bash-completion/bash_completion"
      return
    }
  done
}

## Load bash completions
load_bash_completion
  


## ``source'' builtin override
## Allows directories to be sourced recursively
source() {
  if [[ -d $1 ]]; then
    for _ in "$1"/*; do
      if [[ -f $_ || -d $_ && $_ != */.?(.) ]]; then
        source "$_" "${@:2}"
      fi
    done
  else
    builtin source "$@"
  fi
}

## Load additional configuration
source ~/.bashrc.d



# vi:et:sts=2:sw=2:ts=8:tw=80
