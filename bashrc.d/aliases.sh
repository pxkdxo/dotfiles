## bash_aliases : alias definitions for interactive shells


## Function for defining multiple aliases from a template
aliasfmt() {
  
  if test "$#" -lt 2; then
    printf 'usage: %q sub fmt [name ...]\n' "${FUNCNAME[@]::1}" >&2
    return 2
  fi

  set -- "${@/%/=$2}" "$1"
  shift 2
  while test "$#" -gt 1; do
    set -- "${1%%=*}" "${1#*=}" "${@:2}"
    alias $1=${2//"${!#}"/"${BASH_ALIASES["$1"]:-"$1"}"}
    shift 2
  done
}



## -- expand 2nd word --

alias sudo="'sudo' "
alias nohup="'nohup' "
alias rlwrap="'rlwrap' "
alias unbuffer="'unbuffer' "



## -- default options --

alias ls="'ls' --color"
alias dir="'dir' --color"
alias vdir="'vdir' --color"

alias grep="'grep' --color"
alias egrep="'egrep' --color"
alias fgrep="'fgrep' --color"

alias jobs="'jobs' -l"

alias mkdir="'mkdir' -pv"

alias mv="'mv' -biv"

alias rm="'rm' -Idv"

case " $(command rename --version) " in
  (*\ 2.32[.\ ]*)
    alias rename="'rename' -ov"
    ;;
  (*)
    alias rename="'rename' -v"
    ;;
esac

alias rsync="'rsync' --human-readable --progress"

alias shred="'shred' --random-source=/dev/random"
alias shuf="'shuf' --random-source=/dev/urandom"
alias sort="'sort' --random-source=/dev/urandom"



## -- command overrides --

alias which='type -P'

if command -v htop 1>/dev/null; then
  alias top='htop'
fi



## -- builtin shortcuts --

alias ech='echo'

alias l='ls'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'
alias lr='ls -R'

alias pf='printf'
alias pf.d='printf '"'"'%d\n'"'"
alias pf.i='printf '"'"'%i\n'"'"
alias pf.o='printf '"'"'%o\n'"'"
alias pf.u='printf '"'"'%u\n'"'"
alias pf.x='printf '"'"'%x\n'"'"
alias pf.X='printf '"'"'%X\n'"'"
alias pf.f='printf '"'"'%f\n'"'"
alias pf.e='printf '"'"'%e\n'"'"
alias pf.E='printf '"'"'%E\n'"'"
alias pf.g='printf '"'"'%g\n'"'"
alias pf.G='printf '"'"'%G\n'"'"
alias pf.c='printf '"'"'%c\n'"'"
alias pf.s='printf '"'"'%s\n'"'"
alias pf.b='printf '"'"'%b\n'"'"
alias pf.q='printf '"'"'%q\n'"'"



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

alias xc0i='xclip -sel clipboard -i'
alias xc0o='xclip -sel clipboard -o'
alias xc0f='xclip -sel clipboard -f'
alias xc0r='xclip -sel clipboard -r'

alias xc1i='xclip -sel primary -i'
alias xc1o='xclip -sel primary -o'
alias xc1f='xclip -sel primary -f'
alias xc1r='xclip -sel primary -r'

alias xc2i='xclip -sel secondary -i'       
alias xc2o='xclip -sel secondary -o'      
alias xc2f='xclip -sel secondary -f'   
alias xc2r='xclip -sel secondary -r' 
         


## -- pacman shortcuts --

alias pac=\
'pacman'

alias pac.d=\
'pacman --database'
alias pac.dk=\
'pacman --database --check'
alias pac.dkk=\
'pacman --database --check -k'

alias pac.f=\
'pacman --files'
alias pac.fl=\
'pacman --files --list'
alias pac.fo=\
'pacman --files --owns'
alias pac.fs=\
'pacman --files --search --regex'
alias pac.fy=\
'sudo pacman --files --refresh'
alias pac.fyy=\
'sudo pacman --files --refresh -y'

alias pac.q=\
'pacman --query'
alias pac.qd=\
'pacman --query --deps'
alias pac.qdms=\
'pacman --query --deps --foreign --search'
alias pac.qdmt=\
'pacman --query --deps --foreign --unrequired'
alias pac.qdmtt=\
'pacman --query --deps --foreign --unrequired -t'
alias pac.qdns=\
'pacman --query --deps --native --search'
alias pac.qdnt=\
'pacman --query --deps --native --unrequired'
alias pac.qdntt=\
'pacman --query --deps --native --unrequired -t'
alias pac.qdt=\
'pacman --query --deps --unrequired'
alias pac.qdtt=\
'pacman --query --deps --unrequired -t'
alias pac.qe=\
'pacman --query --explicit'
alias pac.qems=\
'pacman --query --explicit --foreign --search'
alias pac.qemt=\
'pacman --query --explicit --foreign --unrequired'
alias pac.qemtt=\
'pacman --query --explicit --foreign --unrequired -t'
alias pac.qens=\
'pacman --query --explicit --native --search'
alias pac.qent=\
'pacman --query --explicit --native --unrequired'
alias pac.qentt=\
'pacman --query --explicit --native --unrequired -t'
alias pac.qet=\
'pacman --query --explicit --unrequired'
alias pac.qett=\
'pacman --query --explicit --unrequired -t'
alias pac.qg=\
'pacman --query --groups'
alias pac.qgs=\
'pacman --query --groups --search'
alias pac.qi=\
'pacman --query --info'
alias pac.qk=\
'pacman --query --check'
alias pac.qkk=\
'pacman --query --check -k'
alias pac.ql=\
'pacman --query --list'
alias pac.qm=\
'pacman --query --foreign'
alias pac.qms=\
'pacman --query --foreign --search'
alias pac.qmt=\
'pacman --query --foreign --unrequired'
alias pac.qmtt=\
'pacman --query --foreign --unrequired -t'
alias pac.qn=\
'pacman --query --native'
alias pac.qns=\
'pacman --query --native --search'
alias pac.qnt=\
'pacman --query --native --unrequired'
alias pac.qntt=\
'pacman --query --native --unrequired -t'
alias pac.qo=\
'pacman --query --owns'
alias pac.qs=\
'pacman --query --search'
alias pac.qt=\
'pacman --query --unrequired'
alias pac.qtt=\
'pacman --query --unrequired -t'
alias pac.qu=\
'pacman --query --upgrades'


alias pac.r=\
'sudo pacman --remove --nodeps --recursive --unneeded'
alias pac.rcs=\
'sudo pacman --remove --nodeps --cascade --recursive --unneeded'
alias pac.rcss=\
'sudo pacman --remove --nodeps --cascade --recursive -s --unneeded'
alias pac.rss=\
'sudo pacman --remove --nodeps --recursive -s --unneeded'


alias pac.s=\
'sudo pacman --sync'
alias pac.sc=\
'sudo pacman --sync --clean'
alias pac.scc=\
'sudo pacman --sync --clean -c'
alias pac.sg=\
'pacman --sync --groups'
alias pac.si=\
'pacman --sync --info'
alias pac.sl=\
'pacman --sync --list'
alias pac.ss=\
'pacman --sync --search'
alias pac.su=\
'sudo pacman --sync --sysupgrade'
alias pac.suy=\
'sudo pacman --sync --sysupgrade --refresh'
alias pac.suyy=\
'sudo pacman --sync --sysupgrade --refresh -y'
alias pac.sy=\
'sudo pacman --sync --refresh'
alias pac.syy=\
'sudo pacman --sync --refresh -y'


alias pac.u=\
'sudo pacman --upgrade'



## -- docker --

alias doc='docker'

alias doc.stopall='docker stop $(docker ps -q) 2>/dev/null'

alias doc.killall='docker kill $(docker ps -q) 2>/dev/null'

alias doc.rmdead='docker rm $(docker ps -aq) 2>/dev/null'

alias doc.rmall='{
docker kill $(docker ps -q)
docker rm $(docker ps -aq)
} 2>/dev/null'

alias doc.jupyter='
docker run --detach --tty --publish 8888:8888 --volume ~:/home/jovyan/work jupyter/datascience-notebook'



## -- poor-man's functions --

## find a file non-recursively in the current directory
alias findcwd='find . -maxdepth 1'


## Print groups in member/non-member columns each sorted by gid
alias usergroups='column \
  --table \
  --separator=$'"'"'\t'"'"' \
  --output-separator=$'"'"'\t'"'"' \
  <(paste --delimiters=$'"'"'\t'"'"' \
    <(grep "${USER}" /etc/group \
      | sort \
        --field-separator=: \
        --key=3g \
      | column \
        --separator=: \
        --table \
        --table-columns=GROUP,X,GID,USERS \
        --table-hide=X
    ) \
    <(grep --invert-match "${USER}" /etc/group \
      | sort \
        --field-separator=: \
        --key=3g \
      | column \
        --separator=: \
        --table \
        --table-columns=GROUP,X,GID,USERS \
        --table-hide=X
    ) | sed -E '"'"'s/^\s+/-\t/'"'"'
  ) | expand'


## download audio from youtube into ~/Music with available metadata
alias ydla='youtube-dl \
  --extract-audio \
  --audio-quality 0 \
  --console-title \
  --format "bestaudio/best" \
  --output "${HOME}/Music/%(title)s.%(ext)s" \
  --geo-bypass \
  --ignore-errors \
  --playlist-random \
  --min-sleep-interval 1 \
  --max-sleep-interval 7 \
  --add-metadata \
  --metadata-from-title \
    '"'"'^((?P<artist>.+?)\s+-\s+((?P<album>.+)\s+-\s+)?)?(?P<title>.+?)$'"'"
