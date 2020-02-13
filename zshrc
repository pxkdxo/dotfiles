## .zshrc : zsh 5.4.1 interactive shell initialization file


## Load plugins from zsh data directory
() {
  while (( $# )) do {
    source "$1"
    shift
  } done
} "${XDG_DATA_HOME:-"${HOME}/.local/share"}/zsh/plugins"/*/*.zsh(.N)

mkdir -p -m 0700 "${XDG_CACHE_HOME:-"${HOME}/.cache"}/zsh"

zstyle ':completion:*' add-space true
zstyle ':completion:*' completer _expand _complete _ignored _match _approximate _prefix
zstyle ':completion:*' completions 1
zstyle ':completion:*' condition 0


#zstyle ':completion:*' format "%U%B %d%u%b"

zstyle ':completion:*' glob 1

#zstyle ':completion:*' group-name ''

zstyle ':completion:*' ignore-parents parent pwd directory

zstyle ':completion:*' insert-unambiguous true

#zstyle ':completion:*' list-colors \
#  ${(s.:.)${LS_COLORS:=${${(s.\'.)$(
#    dircolors -b (${XDG_CONFIG_HOME:-~/.config}/|~/.)dircolors(#q.N)
#  )}[2]}}}

zstyle ':completion:*' list-prompt \
  '%SShowing %l (%p), Tab/Space:PgDn, Enter:LnDn%s'

zstyle ':completion:*' list-suffixes true

zstyle ':completion:*' matcher-list \
  '+m:{[:lower:]}={[:upper:]} r:|[._-:]=* r:|=*' '' '' 'l:|=* r:|=*'

zstyle ':completion:*' match-original both

zstyle ':completion:*' max-errors 3 numeric

zstyle ':completion:*' menu select=2

zstyle ':completion:*' original false

zstyle ':completion:*' preserve-prefix \
  '//[^/]##/'

zstyle ':completion:*' select-prompt \
  '%SScrolling %l (%p)%s'

zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' substitute 1

zstyle ':completion:*' word true

zstyle ':compinstall'  filename ~/.zshrc

autoload -Uz compinit
compinit

if test -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"; then
  HISTFILE="${XDG_CACHE_HOME:-"${HOME}/.cache"}/zsh/history"
fi

HISTSIZE=32767
SAVEHIST=30000

#bindkey -v

setopt AlwaysToEnd
setopt AutoCd
setopt AutoContinue
setopt AutoPushd
setopt NoBeep
setopt BraceCcl
setopt CBases
setopt CdableVars
setopt CompleteInWord
setopt ExtendedGlob
setopt GlobComplete
setopt GlobStarShort
setopt HistExpireDupsFirst
setopt HistFindNoDups
setopt HistIgnoreDups
setopt HistLexWords
setopt HistReduceBlanks
setopt HistSubstPattern
setopt HistVerify
setopt IncAppendHistory
setopt ListPacked
setopt LongListJobs
setopt PosixBuiltins
setopt PromptSubst
setopt PushdMinus
setopt RcExpandParam
setopt RematchPcre


PS1='%B%n%b@%B%m%b:%B%(3~+../../+)%2~/%b
%B%(0?^^%${?}F${?})%#%f%b '



# vim:ft=zsh
