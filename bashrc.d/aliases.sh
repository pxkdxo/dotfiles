#!/usr/bin/env bash
#
## bash_aliases : alias definitions
#

## -- expand aliases following these commands --

alias sudo='sudo '
alias nohup='nohup '
alias unbuffer='unbuffer '


## -- default options --

alias ls='ls --color=always'
alias dir='dir --color=always'
alias vdir='vdir --color=always'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias fgrep='fgrep --color=always'
alias pcre2grep='pcre2grep --color=always'

alias shred='shred --random-source=/dev/random'
alias shuf='shuf --random-source=/dev/random'
alias sort='sort --random-source=/dev/random'

alias jobs='jobs -l'
alias mv='mv -ibv'
alias rm='rm -Idv'
alias mkdir='mkdir -pv'
alias rename='rename -ov'


## -- command overrides --

alias which='type -P'

type -P htop >/dev/null &&
  alias top='htop'


## -- builtin shortcuts --

alias ech='echo'

alias l='ls'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'

alias pu='pushd'
alias po='popd'

alias pf='printf'
alias pf-d='printf '"'"'%d'"'"
alias pf-i='printf '"'"'%i'"'"
alias pf-o='printf '"'"'%o'"'"
alias pf-u='printf '"'"'%u'"'"
alias pf-x='printf '"'"'%x'"'"
alias pf-X='printf '"'"'%X'"'"
alias pf-f='printf '"'"'%f'"'"
alias pf-e='printf '"'"'%e'"'"
alias pf-E='printf '"'"'%E'"'"
alias pf-g='printf '"'"'%g'"'"
alias pf-G='printf '"'"'%G'"'"
alias pf-c='printf '"'"'%c'"'"
alias pf-s='printf '"'"'%s'"'"
alias pf-b='printf '"'"'%b'"'"
alias pf-q='printf '"'"'%q'"'"
alias pf-dn='printf '"'"'%d\n'"'"
alias pf-in='printf '"'"'%i\n'"'"
alias pf-on='printf '"'"'%o\n'"'"
alias pf-un='printf '"'"'%u\n'"'"
alias pf-xn='printf '"'"'%x\n'"'"
alias pf-Xn='printf '"'"'%X\n'"'"
alias pf-fn='printf '"'"'%f\n'"'"
alias pf-en='printf '"'"'%e\n'"'"
alias pf-En='printf '"'"'%E\n'"'"
alias pf-gn='printf '"'"'%g\n'"'"
alias pf-Gn='printf '"'"'%G\n'"'"
alias pf-cn='printf '"'"'%c\n'"'"
alias pf-sn='printf '"'"'%s\n'"'"
alias pf-bn='printf '"'"'%b\n'"'"
alias pf-qn='printf '"'"'%q\n'"'"


## -- External Cmd Shortcuts --

alias gpg-d='gpg --decrypt'
alias gpg-e='gpg --symmetric'
alias gpg-s='gpg --sign'

alias mkvenv='mkvirtualenv'
alias cdvenv='cdvirtualenv'
alias lsvenv='lsvirtualenv'
alias rmvenv='rmvirtualenv'

alias pcre='pcre2grep'

alias p='python'
alias p2='python2'
alias p3='python3'

alias xc0='xclip -sel clip'
alias xc0i='xclip -sel clip -i'
alias xc0o='xclip -sel clip -o'
alias xc0f='xclip -sel clip -f'
alias xc0r='xclip -sel clip -r'

alias xc1='xclip -sel pri'
alias xc1i='xclip -sel pri -i'
alias xc1o='xclip -sel pri -o'
alias xc1f='xclip -sel pri -f'
alias xc1r='xclip -sel pri -r'

alias xc2='xclip -sel sec'       
alias xc2i='xclip -sel sec -i'       
alias xc2o='xclip -sel sec -o'      
alias xc2f='xclip -sel sec -f'   
alias xc2r='xclip -sel sec -r' 
         

## -- pacman abbrevs --

alias pacd=\
'pacman --database'
alias pacdk=\
'pacman --database -k'
alias pacdkk=\
'pacman --database -kk'

alias pacf=\
'pacman --files'
alias pacfl=\
'pacman --files -l'
alias pacfo=\
'pacman --files -o'
alias pacfs=\
'pacman --files -sx'
alias pacfy=\
'sudo pacman --files -y'
alias pacfyy=\
'sudo pacman --files -yy'

alias pacq=\
'pacman --query'
alias pacqd=\
'pacman --query -d'
alias pacqdms=\
'pacman --query -dms'
alias pacqdmt=\
'pacman --query -dmt'
alias pacqdmtt=\
'pacman --query -dmtt'
alias pacqdt=\
'pacman --query -dt'
alias pacqdtt=\
'pacman --query -dtt'
alias pacqe=\
'pacman --query -e'
alias pacqems=\
'pacman --query -ems'
alias pacqemt=\
'pacman --query -emt'
alias pacqemtt=\
'pacman --query -emtt'
alias pacqet=\
'pacman --query -et'
alias pacqett=\
'pacman --query -ett'
alias pacqg=\
'pacman --query -g'
alias pacqgs=\
'pacman --query -gs'
alias pacqi=\
'pacman --query -i'
alias pacqk=\
'pacman --query -k'
alias pacqkk=\
'pacman --query -kk'
alias pacql=\
'pacman --query -l'
alias pacqm=\
'pacman --query -m'
alias pacqms=\
'pacman --query -ms'
alias pacqmt=\
'pacman --query -mt'
alias pacqmtt=\
'pacman --query -mtt'
alias pacqn=\
'pacman --query -n'
alias pacqns=\
'pacman --query -ns'
alias pacqnt=\
'pacman --query -nt'
alias pacqntt=\
'pacman --query -ntt'
alias pacqo=\
'pacman --query -o'
alias pacqs=\
'pacman --query -s'
alias pacqt=\
'pacman --query -t'
alias pacqtt=\
'pacman --query -tt'
alias pacqu=\
'pacman --query -u'

alias pacr=\
'pacman --remove -du'
alias pacrcs=\
'pacman --remove -dcsu'
alias pacrcss=\
'pacman --remove -dcssu'
alias pacrs=\
'pacman --remove -dsu'
alias pacrss=\
'pacman --remove -dssu'

alias pacs=\
'sudo pacman --sync'
alias pacsc=\
'sudo pacman --sync -c'
alias pacscc=\
'sudo pacman --sync -cc'
alias pacsg=\
'pacman --sync -g'
alias pacsgs=\
'pacman --sync -gs'
alias pacsi=\
'pacman --sync -i'
alias pacsl=\
'pacman --sync -l'
alias pacss=\
'pacman --sync -s'
alias pacsu=\
'sudo pacman --sync -u'
alias pacsuy=\
'sudo pacman --sync -uy'
alias pacsuyy=\
'sudo pacman --sync -uyy'
alias pacsy=\
'sudo pacman --sync -y'
alias pacsyy=\
'sudo pacman --sync -yy'

alias pacu=\
'sudo pacman --upgrade'


## -- Docker --

alias docker.jupyter='
docker run --detach --tty --publish 8888:8888 --volume ~:/home/jovyan/work \
  jupyter/datascience-notebook'

alias docker.stopall='docker stop $(docker ps -q) 2>/dev/null'

alias docker.killall='docker kill $(docker ps -q) 2>/dev/null'

alias docker.rmdead='docker rm $(docker ps -aq) 2>/dev/null'

alias docker.rmall='{
docker kill $(docker ps -q)
docker rm $(docker ps -aq)
} 2>/dev/null'



## -- Poor-Man's Functions --

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


## Download audio from youtube into ~/Music with available metadata
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
