#!/usr/bin/env bash
#
## bash_aliases : alias definitions
#

## -- expand aliases following these commands --

alias sudo='sudo '
alias nohup='nohup '
alias unbuffer='unbuffer '


## -- default options --

alias -- ls='ls --color=always'
alias -- dir='dir --color=always'
alias -- vdir='vdir --color=always'
alias -- grep='grep --color=always'
alias -- egrep='egrep --color=always'
alias -- fgrep='fgrep --color=always'
alias -- pcre2grep='pcre2grep --color=always'

alias -- shred='shred --random-source=/dev/random'
alias -- shuf='shuf --random-source=/dev/random'
alias -- sort='sort --random-source=/dev/random'

alias -- jobs='jobs -l'
alias -- mv='mv -ibv'
alias -- rm='rm -Idv'
alias -- mkdir='mkdir -pv'
alias -- rename='rename -ov'


## -- command overrides --

alias -- which='type -P'

type -P htop >/dev/null &&
  alias -- top='htop'


## -- builtin shortcuts --

alias -- ech='echo'

alias -- l='ls'
alias -- la='ls -A'
alias -- ll='ls -l'
alias -- lla='ls -lA'

alias -- pu='pushd'
alias -- po='popd'

alias -- pf='printf'

alias -- pf.d='printf '"'"'%d'"'"
alias -- pf.i='printf '"'"'%i'"'"
alias -- pf.o='printf '"'"'%o'"'"
alias -- pf.u='printf '"'"'%u'"'"
alias -- pf.x='printf '"'"'%x'"'"
alias -- pf.X='printf '"'"'%X'"'"
alias -- pf.f='printf '"'"'%f'"'"
alias -- pf.e='printf '"'"'%e'"'"
alias -- pf.E='printf '"'"'%E'"'"
alias -- pf.g='printf '"'"'%g'"'"
alias -- pf.G='printf '"'"'%G'"'"
alias -- pf.c='printf '"'"'%c'"'"
alias -- pf.s='printf '"'"'%s'"'"
alias -- pf.b='printf '"'"'%b'"'"
alias -- pf.q='printf '"'"'%q'"'"

alias -- pf.dn='printf '"'"'%d\n'"'"
alias -- pf.in='printf '"'"'%i\n'"'"
alias -- pf.on='printf '"'"'%o\n'"'"
alias -- pf.un='printf '"'"'%u\n'"'"
alias -- pf.xn='printf '"'"'%x\n'"'"
alias -- pf.Xn='printf '"'"'%X\n'"'"
alias -- pf.fn='printf '"'"'%f\n'"'"
alias -- pf.en='printf '"'"'%e\n'"'"
alias -- pf.En='printf '"'"'%E\n'"'"
alias -- pf.gn='printf '"'"'%g\n'"'"
alias -- pf.Gn='printf '"'"'%G\n'"'"
alias -- pf.cn='printf '"'"'%c\n'"'"
alias -- pf.sn='printf '"'"'%s\n'"'"
alias -- pf.bn='printf '"'"'%b\n'"'"
alias -- pf.qn='printf '"'"'%q\n'"'"


## -- External Cmd Shortcuts --

alias -- py='python'

alias -- xc.c='xclip -selection clipboard'
alias -- xc.p='xclip -selection primary'
alias -- xc.s='xclip -selection secondary'

alias -- mkvenv='mkvirtualenv'
alias -- cdvenv='cdvirtualenv'
alias -- lsvenv='lsvirtualenv'
alias -- rmvenv='rmvirtualenv'

alias -- pcre='pcre2grep'

alias -- pac.d='pacman --database'
alias -- pac.f='pacman --files'
alias -- pac.q='pacman --query'
alias -- pac.r='pacman --remove'
alias -- pac.s='pacman --sync'
alias -- pac.u='pacman --upgrade'

alias -- gpg-d='gpg --decrypt'
alias -- gpg-e='gpg --symmetric'
alias -- gpg-s='gpg --sign'


## -- Docker --

alias -- docker.jupyter=\
'docker run                                                           \
  --detach                                                            \
  --tty                                                               \
  --publish 8888:8888                                                 \
  --volume ~/Documents/jupyter/datascience-notebook:/home/jovyan/work \
  jupyter/datascience-notebook'

alias -- docker.stopall='docker stop $(docker ps -q) 2>/dev/null'

alias -- docker.killall='docker kill $(docker ps -q) 2>/dev/null'

alias -- docker.rmdead='docker rm $(docker ps -aq) 2>/dev/null'

alias -- docker.rmall=\
'{ docker kill $(docker ps -q); docker rm $(docker ps -aq); } 2>/dev/null'



## Poor-Man's Functions
#

## find non-recursively in the current directory
alias -- findcwd='find . -maxdepth 1'


## Print groups in member/non-member columns each sorted by gid
alias -- usergroups=\
'column \
  --separator=$'"'"'\t'"'"' \
  --table \
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


## Download audio from youtube into ~/Music with available metadata
alias -- ydla=\
'youtube-dl \
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
