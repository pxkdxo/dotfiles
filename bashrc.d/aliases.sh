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

alias pac-d=\
'pacman --database'
alias pac-dk=\
'pacman --database -k'
alias pac-dkk=\
'pacman --database -kk'

alias pac-f=\
'pacman --files'
alias pac-fl=\
'pacman --files -l'
alias pac-fo=\
'pacman --files -o'
alias pac-fs=\
'pacman --files -sx'
alias pac-fy=\
'sudo pacman --files -y'
alias pac-fyy=\
'sudo pacman --files -yy'

alias pac-q=\
'pacman --query'
alias pac-qd=\
'pacman --query -d'
alias pac-qdms=\
'pacman --query -dms'
alias pac-qdmt=\
'pacman --query -dmt'
alias pac-qdmtt=\
'pacman --query -dmtt'
alias pac-qdt=\
'pacman --query -dt'
alias pac-qdtt=\
'pacman --query -dtt'
alias pac-qe=\
'pacman --query -e'
alias pac-qems=\
'pacman --query -ems'
alias pac-qemt=\
'pacman --query -emt'
alias pac-qemtt=\
'pacman --query -emtt'
alias pac-qet=\
'pacman --query -et'
alias pac-qett=\
'pacman --query -ett'
alias pac-qg=\
'pacman --query -g'
alias pac-qgs=\
'pacman --query -gs'
alias pac-qi=\
'pacman --query -i'
alias pac-qk=\
'pacman --query -k'
alias pac-qkk=\
'pacman --query -kk'
alias pac-ql=\
'pacman --query -l'
alias pac-qm=\
'pacman --query -m'
alias pac-qms=\
'pacman --query -ms'
alias pac-qmt=\
'pacman --query -mt'
alias pac-qmtt=\
'pacman --query -mtt'
alias pac-qn=\
'pacman --query -n'
alias pac-qns=\
'pacman --query -ns'
alias pac-qnt=\
'pacman --query -nt'
alias pac-qntt=\
'pacman --query -ntt'
alias pac-qo=\
'pacman --query -o'
alias pac-qs=\
'pacman --query -s'
alias pac-qt=\
'pacman --query -t'
alias pac-qtt=\
'pacman --query -tt'
alias pac-qu=\
'pacman --query -u'

alias pac-r=\
'pacman --remove -du'
alias pac-rcs=\
'pacman --remove -dcsu'
alias pac-rcss=\
'pacman --remove -dcssu'
alias pac-rs=\
'pacman --remove -dsu'
alias pac-rss=\
'pacman --remove -dssu'

alias pac-s=\
'sudo pacman --sync'
alias pac-sc=\
'sudo pacman --sync -c'
alias pac-scc=\
'sudo pacman --sync -cc'
alias pac-sg=\
'pacman --sync -g'
alias pac-sgs=\
'pacman --sync -gs'
alias pac-si=\
'pacman --sync -i'
alias pac-sl=\
'pacman --sync -l'
alias pac-ss=\
'pacman --sync -s'
alias pac-su=\
'sudo pacman --sync -u'
alias pac-suy=\
'sudo pacman --sync -uy'
alias pac-suyy=\
'sudo pacman --sync -uyy'
alias pac-sy=\
'sudo pacman --sync -y'
alias pac-syy=\
'sudo pacman --sync -yy'

alias pac-u=\
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
