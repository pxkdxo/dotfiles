## Alias definitions for interactive shells
## maintained by Patrick DeYoreo


## Function for defining multiple aliases from a template
aliasfmt() {

  ## Too few arguments, then print usage message and return
  test "$#" -lt 2 && {
    printf 'usage: %q to-replace template [name ...]\n' "${FUNCNAME[@]::1}" 1>&2
    return 2
  }
  
  ## Make args template assignments & append the placeholder to the arg list
  set -- "${@/%/=$2}" "$1"

  ## Shift past the template and the placeholder
  shift 2

  ## For each remaining argument except the last, make an alias 
  while test "$#" -gt 1; do
    set -- "${1%%=*}" "${1#*=}" "${@:2}"
    alias "$1=${2//"${!#}"/"${BASH_ALIASES["$1"]:-"$1"}"}"
    shift 2
  done
}



## -- expand next word --

alias exec="${BASH_ALIASES["exec"]:-"exec"} "

alias nohup="${BASH_ALIASES["nohup"]:-"nohup"} "

alias sudo="${BASH_ALIASES["sudo"]:-"sudo"} "

alias rlwrap="${BASH_ALIASES["rlwrap"]:-"rlwrap"} "

alias unbuffer="${BASH_ALIASES["unbuffer"]:-"unbuffer"} "



## -- default options --


alias jobs='jobs -l'

alias ls='ls -Cp'

alias mkdir='mkdir -pv'

alias mv='mv -biv'

alias rm='rm -Iv'

alias rename='rename -ov'

alias rsync='rsync --progress'

alias shred='shred --random-source=/dev/random'

alias shuf='shuf --random-source=/dev/random'

alias sort='sort --random-source=/dev/random'



## -- colored output --

alias ls="${BASH_ALIASES["ls"]:-"ls"} --color=auto"

alias dir="${BASH_ALIASES["dir"]:-"dir"} --color=auto"

alias vdir="${BASH_ALIASES["vdir"]:-"vdir"} --color=auto"

alias grep="${BASH_ALIASES["grep"]:-"grep"} --color=auto"

alias egrep="${BASH_ALIASES["egrep"]:-"egrep"} --color=auto"

alias fgrep="${BASH_ALIASES["fgrep"]:-"fgrep"} --color=auto"

alias pcre2grep="${BASH_ALIASES["pcre2grep"]:-"pcre2grep"} --color=auto"



## -- command overrides --

#alias which='type -P'

if command -v 'htop' 1>/dev/null; then
  alias top='htop'
fi



## -- builtins --

alias ech='echo'

alias l='ls'
alias ll='ls -l'
alias la='ls -A'
alias lr='ls -R'
alias lla='ls -lA'
alias llr='ls -lR'

alias j='jobs'

alias mkd='mkdir'

alias pf='printf'

alias pf.c='pf.intf '"'"'%c\n'"'"
alias pf.s='pf.intf '"'"'%s\n'"'"
alias pf.b='pf.intf '"'"'%b\n'"'"
alias pf.q='pf.intf '"'"'%q\n'"'"

alias pf.d='printf '"'"'%#d\n'"'"
alias pf,d='printf '"'"'%#'"'"'"'"'"'"'"'"'d\n'"'"

alias pf.i='printf '"'"'%#i\n'"'"
alias pf,i='printf '"'"'%#'"'"'"'"'"'"'"'"'i\n'"'"

alias pf.u='printf '"'"'%#u\n'"'"
alias pf,u='printf '"'"'%#'"'"'"'"'"'"'"'"'u\n'"'"

alias pf.o='printf '"'"'%#o\n'"'"
alias pf,o='printf '"'"'%#'"'"'"'"'"'"'"'"'o\n'"'"

alias pf.x='printf '"'"'%#x\n'"'"
alias pf,x='printf '"'"'%#'"'"'"'"'"'"'"'"'x\n'"'"

alias pf.X='printf '"'"'%#X\n'"'"
alias pf,X='printf '"'"'%#'"'"'"'"'"'"'"'"'X\n'"'"

alias pf.a='printf '"'"'%#a\n'"'"
alias pf.A='printf '"'"'%#A\n'"'"

alias pf.f='printf '"'"'%#f\n'"'"
alias pf,f='printf '"'"'%#'"'"'"'"'"'"'"'"'f\n'"'"

alias pf.e='printf '"'"'%#e\n'"'"
alias pf,E='printf '"'"'%#E\n'"'"

alias pf.g='printf '"'"'%#g\n'"'"
alias pf,g='printf '"'"'%#'"'"'"'"'"'"'"'"'g\n'"'"

alias pf.G='printf '"'"'%#G\n'"'"
alias pf,G='printf '"'"'%#'"'"'"'"'"'"'"'"'G\n'"'"



## -- system command shortcuts --

alias jctl='journalctl'
alias sctl='systemctl'
alias mctl='machinectl'

alias jctlu='journalctl --user'
alias sctlu='systemctl --user'

alias m='mpv'


## -- external command shortcuts --

alias mkvenv='mkvirtualenv'
alias cdvenv='cdvirtualenv'
alias lsvenv='lsvirtualenv'
alias rmvenv='rmvirtualenv'

alias p='python'
alias py='python'

alias p2='python2'
alias py2='python2'

alias p3='python3'
alias py3='python3' 

if command -v 'python3' 1>/dev/null; then
  alias python='python3'
fi

alias xc='xclip -sel clipboard'
alias xc.i='xclip -sel clipboard -i'
alias xc.o='xclip -sel clipboard -o'
alias xc.f='xclip -sel clipboard -f'
alias xc.r='xclip -sel clipboard -r'

alias xc1='xclip -sel primary'
alias xc1.i='xclip -sel primary -i'
alias xc1.o='xclip -sel primary -o'
alias xc1.f='xclip -sel primary -f'
alias xc1.r='xclip -sel primary -r'

alias xc2='xclip -sel secondary'       
alias xc2.i='xclip -sel secondary -i'       
alias xc2.o='xclip -sel secondary -o'      
alias xc2.f='xclip -sel secondary -f'   
alias xc2.r='xclip -sel secondary -r' 
          


## -- docker --

alias doc='docker'

alias doc.stopall='docker stop $(docker ps -q) 2>/dev/null'

alias doc.killall='docker kill $(docker ps -q) 2>/dev/null'

alias doc.rmdead='docker rm $(docker ps -aq) 2>/dev/null'

alias doc.rmall="\
{ docker kill \$(docker ps -q)
  docker rm \$(docker ps -aq)
} 2>/dev/null"



## Create a new jupyter datascience notebook container
doc.jupyter() {

  ## Initialize local variables
  local help='' cmd=( docker run --tty ) || return 3

  ## Construct help message
  printf -v help '%q: usage: %q [-d] [-p host-port] [-v host-directory]' \
      "${0##*/}" "${FUNCNAME[@]::1}"

  ## Parse options
  while (( $# )); do
    case "${1:0:1}" in
      -)
        case "${1:1}" in

          p|-port)
            shift
            cmd+=( -p "${2:-"${JOVYAN_PORT:-"8888"}"}:8888" )
            shift && shift || break
            ;;

          v|-volume)
            cmd+=( -v "${2:-"${JOVYAN_WORK:-"${PWD}"}"}:/home/jovyan/work" )
            shift && shift || break
            ;;

          d|-detach)
            cmd+=( -d )
            shift
            ;;

          h|-help)
            printf '%s\n' "${help}"
            return 0
            ;;

          *)
            printf '%s\n' "${help}" 1>&2
            return 2
            ;;

        esac
        ;;

      *)
        printf '%s\n' "${help}" 1>&2
        return 2
        ;;

    esac
  done

  ## Run jupyter nb
  "${cmd[@]}" jupyter/datascience-notebook
}


## -- mpv --

alias yp='mpv --ytdl  --ytdl-format=bestaudio+bestvideo/best'

alias ypa='mpv --force=window --vid=no --ytdl --ytdl-format=bestaudio/best'



## -- poor-man's functions --

## find non-recursively in the current directory (absolute)
alias findhere='find ./ -maxdepth 1'



## -- youtube-dl --

alias yd='youtube-dl'


## download audio from youtube with available metadata
yda() {
  youtube-dl \
  --extract-audio \
  --audio-quality 0 \
  --console-title \
  --format 'bestaudio/best' \
  --output
    "${XDG_MUSIC_DIR:-"${HOME}/Music"}/%(title)s-%(acodec)s-%(asr)nHz-%(abr)nkBps.%(ext)s" \
  --geo-bypass \
  --ignore-errors \
  --playlist-random \
  --min-sleep-interval 1 \
  --max-sleep-interval 5 \
  --add-metadata \
  --metadata-from-title \
    '^((?P<artist>.+?)\s+-\s+((?P<album>.+?)\s+-\s+)?)?(?P<title>.+?)$' \
  "$@"
}


## download youtube audio from link in clipboard
yda.sel() {

  if [[ 'clipboard' =~ "$1" || 'primary' =~ "$1" || 'secondary' =~ "$1" ]]; then

    yda "$(xclip -o -selection "${1:-"clipboard"}")"

  else
    { printf '%q: %q: %q: invalid selection\n' \
        "${0##*/}" "${FUNCNAME[@]::1}" "$1"

      printf '%q: usage: %q selection\n' \
        "${0##*/}" "${FUNCNAME[@]::1}"

      return 2

    } 1>&2
  fi
}



## Print groups in member/non-member columns each sorted by gid
mygroupstab() {
  column \
    --table \
    --output-separator=$'\t' \
    --separator=$'\t' \
    <(paste \
      --delimiters=$'\t' \
      <(grep "${USER}" /etc/group \
          | sort \
          --field-separator=: \
          --key=3g \
          | column \
          --table \
          --separator=: \
          --table-columns=GROUP,X,GID,USERS \
          --table-hide=X) \
      <(grep -v "${USER}" /etc/group \
          | sort \
          --field-separator=: \
          --key=3g \
          | column \
          --table \
          --separator=: \
          --table-columns=GROUP,X,GID,USERS \
          --table-hide=X) \
        | sed 's/^[[:blank:]]\{1,\}/-\t/') \
    | expand
}


## Fork a copy of executable of the existing parent process
fork_parent() {

  [[ -x /proc/${PPID}/exe ]] || {
    printf 1>&2 '%q: %q: %q: No such file or directory\n' \
      "${0##*/}" "${FUNCNAME[@]::1}" "/proc/${PPID}/exe"
    return 1
  }

  ( PPID="$$" exec -a "$0" "/proc/${PPID}/exe" "$@"
  ) 0</dev/null 1>/dev/null 2>&1 & disown %+
}
