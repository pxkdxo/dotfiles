# ~/.bashrc: bash initialization script for interactive shells


# If this is not an interactive shell, stop
[[ $- == *i* ]] || return 0


# -- Display 

# Check window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Send SIGWINCH to the current shell to initialize LINES and COLUMNS
kill -s SIGWINCH "$$"


# -- Shell Options 

# Inherit ERR traps in functions, command substitutions, and subshells
#set -o errtrace

# Require >| redirection operator to overwrite existing files
set -o noclobber

# Report the status of a terminated background job immediately
set -o notify

# Do not resolve symbolic links when executing builtins (such as cd)
set -o physical


# -- Bash Options 

# If a directory name is given as a command, pass it to cd as an argument
shopt -s autocd

# Confirm commands in the hash table exist before trying to execute them
shopt -s checkhash

# Show jobs before exiting and require confirmation if any are running
shopt -s checkjobs

# Expand directory names upon performing filename completion
shopt -s direxpand

# Attempt to correct mispelled directory names during word completion
shopt -s dirspell

# Send SIGHUP to all jobs when an interactive login shell exits
shopt -s huponexit

# Command substitutions inherit the value of the 'errexit' shell option
shopt -s inherit_errexit

# If job control is off, run the last cmd of a pipeline in the current shell
#shopt -s lastpipe

# Enable programmable completion facilities
shopt -s progcomp


# -- Glob Options 

# Ignore current locale's collating sequence when matching range-expressions
shopt -s globasciiranges

# Enable extended pattern matching features
shopt -s extglob

# ``**'' matches all files and zero or more directories and subdirectories
shopt -s globstar

# Ignore any shared object libraries found while searching for executables
# shellcheck disable=2034
EXECIGNORE='?(/usr?(/local))/lib?(?(x)@(32|64))/**/*.so*(.+([[:digit:]]))'

# Don't match paths ending with an instance of "." or ".."
GLOBIGNORE='*(?(.)*/).?(.)*(/)'

# Assigning GLOBIGNORE sets 'dotglob'; unset it to avoid globbing dotfiles
shopt -u dotglob


# -- History Options 

# Configure the location of the history file
if [[ -d ${XDG_CACHE_HOME:-${HOME-}/.cache}/bash ]]; then
    HISTFILE="${XDG_CACHE_HOME:-${HOME-}/.cache}/bash/history"
else
    HISTFILE="${HOME-}/.bash_history"
fi

# Number of entries that may be kept in memory
HISTSIZE=10000

# Number of entries that may be kept on disk
HISTFILESIZE=10000

# Keep duplicates out of the command history
HISTCONTROL='ignoredups:erasedups'

# Ignore blanks surrounding otherwise immediate duplicates
HISTIGNORE='*([[:blank:]])@(&|fg|bg)*([[:blank:]])'

# Append to the history file instead of overwriting it
shopt -s histappend

# Attempt to save multiline commands as single entries
shopt -s cmdhist

# If 'cmdhist' is enabled, save multiline commands with embedded newlines
shopt -s lithist

# While using readline, load failed history subs into buffer for editing
shopt -s histreedit

# While using readline, load history sub results into buffer for editing
shopt -s histverify


# -- PROMPT_COMMAND 

#if [[ $(trap -p DEBUG) =~ \
#    "'"(.*[;$'\n'])[[:blank:]]*__bp_[[:alnum:]_]*[[:blank:]]*([;$'\n'].*)?"'"
#]]
#then
trap DEBUG
#fi

# Clean up PROMPT_COMMAND
PROMPT_COMMAND="${PROMPT_COMMAND//*([[:blank:]])__pc_precmd_invoke_cmd*([[:blank:]])*($'\n'|;)}"
PROMPT_COMMAND="${PROMPT_COMMAND//*([[:blank:]])__bp_precmd_invoke_cmd*([[:blank:]])*($'\n'|;)}"
PROMPT_COMMAND="${PROMPT_COMMAND//*([[:blank:]])__bp_interactive_mode*([[:blank:]])*($'\n'|;)}"
PROMPT_COMMAND="${PROMPT_COMMAND//__bp_last_ret_value/__pc_last_exit_status}"
PROMPT_COMMAND="${PROMPT_COMMAND##*([[:space:];])}"
PROMPT_COMMAND="${PROMPT_COMMAND%%*([[:space:];])}"
PROMPT_COMMAND="__pc_precmd_invoke_cmd;${PROMPT_COMMAND:+ ${PROMPT_COMMAND};}"

# Refresh precmd functions array
precmd_functions=( "${precmd_functions[@]}" )

# Set the exit status
__pc_set_exit_status()
{
    return "${1:-$(( __pc_last_exit_status = $? ))}"
}

# Run commands from the precmd functions array
__pc_precmd_invoke_cmd()
{
    __pc_last_exit_status=$?

    for _ in "${precmd_functions[@]}"
    do
        if command -v "$_" 1>/dev/null
        then
            __pc_set_exit_status "${__pc_last_exit_status}" "$_"
            "$_"
        fi
    done
    return "${__pc_last_exit_status}"
}

# Add a function to precmd_functions
add_precmd_function()
{
    while (( $# ))
    do
        if (IFS=':' && [[ ":${precmd_functions[*]}:" != *:"$1":* ]])
        then
            precmd_functions+=( "$1" )
        fi
        shift
        precmd_functions=( "${precmd_functions[@]}" )
    done
}

# Remove a function from precmd_functions
remove_precmd_function()
{
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


# -- Prompting

# Initialize a dictionary to hold terminfo data
declare -A ti=( )

# Limit depth of paths produced from '\w' upon prompt expansion
PROMPT_DIRTRIM=3

# Set color_prompt to null to disable (enabled by default)
color_prompt="$(( ${color_prompt-1} ))"

# Enable / disable the line between output and PS1
prompt_line=""

# Print a line across the screen
__print_prompt_line()
{
    local -
    set -o braceexpand
    eval '
    printf '"'"'%.s\u2500'"'"' {1..'"$(( ${COLUMNS:-$(tput cols)} ))"'}
    '
    echo
} 2>/dev/null

# Set the primary prompt
# shellcheck disable=SC2026
__ps1_update() {
    PS1=\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\['"${ti[dim]:=$(tput dim)}"'\]'\
${*:+"\\[$*\\]"}\
${prompt_line:+"\$(__print_prompt_line)"}\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\u'\
'\['"${ti[dim]:=$(tput dim)}"'\]'\
'@'\
'\['"${ti[sgr0]:=$(tput sgr0)}"'\]'\
'\['"${ti[bold]:=$(tput bold)}"'\]'\
'\h'\
'\['"${ti[dim]:=$(tput dim)}"'\]'\
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
# shellcheck disable=SC2026
__ps2_update() {
    PS2=\
'\[${ti[sgr0]:=$(tput sgr0)}\]'\
'\[${ti[bold]:=$(tput bold)}\]'\
"${*:+\[$*\]}"\
'$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') / 10 ))'\
'$(( (LINENO - '"$(( BASH_LINENO[-1] ))"') % 10 ))'\
'\[${ti[sgr0]:=$(tput sgr0)}\]'\
' '
}

# Set the select prompt
__ps3_update() {
    PS3="${PS3:-?> }"
}

# Set the execution-trace prompt
# shellcheck disable=SC2026
__ps4_update() {
    PS4=\
'.'\
'${ti[sgr0]:=$(tput sgr0)}'\
'${ti[bold]:=$(tput bold)}'\
'>'\
'${ti[sgr0]:=$(tput sgr0)}'\
' '
}

# Set the pre-execution prompt
__ps0_update() {
    PS0="${PS0-}"
}

# Update the prompt strings
__ps_update() {
    set -- "$?" "$(
    case "$(( $? && $(( ${color_prompt-1} )) ))" in
        (1) tput setaf "$(( ($? - 1) % 8 + 1 ))"
    esac
    )"
    __ps0_update "$2"
    __ps1_update "$2"
    __ps2_update "$2"
    __ps3_update "$2"
    __ps4_update "$2"

} 2>/dev/null

# Add to precmd functions
add_precmd_function '__ps_update'


# -- Window Titles -

# Configure terminal window titles

TTY="$(tty)"
WINDOW_TITLE="[${TTY#/dev/}] \\u@\\h (\\W)"

if [[ ${TERM} == @(rxvt|vte|xterm)?(-*) ]]
then
    __window_title_update()
    {
        local TTY="${TTY:-$(tty)}"
        local WINDOW_TITLE="${WINDOW_TITLE:-[${TTY#/dev/}] \\u@\\h (\\W)}"

        printf '\e]0;%s\a' "${WINDOW_TITLE@P}"
    }
    add_precmd_function __window_title_update

elif [[ ${TERM} == @(screen|tmux)?(-*) ]]
then
    __window_title_update()
    {
        local TTY="${TTY:-$(tty)}"
        local WINDOW_TITLE="${WINDOW_TITLE:-[${TTY#/dev/}] \\u@\\h (\\W)}"

        # shellcheck disable=SC1003
        printf '\ek%s\e\' "${WINDOW_TITLE@P}"
    }
    add_precmd_function __window_title_update
fi


# -- GnuPG 

# Set GPG_TTY to device on stdin and add it to the environment
GPG_TTY="$(tty -s)" || GPG_TTY=""

export GPG_TTY

# Refresh gpg-agent in case we switched to an Xsession
gpg-connect-agent updatestartuptty /bye &>/dev/null


# -- Lessopen 

# Make less more friendly for non-text input files
if command -v lesspipe 1>/dev/null
then
    eval "$(SHELL="${SHELL:-$(type -P bash)}" lesspipe)"
fi


# -- Bash Completion 

# Load bash-completion, if available, unless posix mode is set
# shellcheck disable=SC1091
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


# -- Bash Aliases 

# Check for bash_aliases file
# shellcheck disable=SC1090
if [[ -f ~/.bash_aliases ]]
then
    source ~/.bash_aliases
fi


# -- Extra Config 

# sourcedir - recursively source a directory
sourcedir()
{
    if [[ -d $1 ]]
    then
        for _ in "$1"/*
        do
            "${FUNCNAME[0]}" "$_" "${@:2}"
        done
    elif [[ -f $1 ]]
    then
        # shellcheck source=/dev/null
        source -- "$@"
    fi
}

# Source additional startup scripts
if [[ -d ~/.bashrc.d ]]
then
    sourcedir ~/.bashrc.d
fi
