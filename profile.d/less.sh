# less.sh : less environment config
# see less(1)

# Default options
# -F, --quit-if-one-screen
# -g, --hilite-search
# -i, --ignore-case
# -M, --LONG-PROMPT
# -q, --quiet
# -R, --RAW-CONTROL-CHARS
# -X, --no-init
# -[z]n, --window=n
export LESS='-FgiMqRX-2'
# Non-printable character representation
export LESSBINFMT='*d<%02x>'
# Non-printable character representation (utf-8)
export LESSUTFBINFMT='<U+%04lx>'
# Characters that may end a video escape sequence
export LESSANSIENDCHARS='m'
# Characters that may compose a video escape sequence
export LESSANSIMIDCHARS="0123456789:;[?!\"'#%()*+ "

# support colors in less
#bold="$(tput bold)"
#sgr0="$(tput sgr0)"
#smso="$(tput smso)"
#smul="$(tput smul)"
#cyan="$(tput setaf 5 || tput setf 5)"
#export LESS_TERMCAP_mb="${bold}${cyan}"
#export LESS_TERMCAP_md="${bold}${cyan}"
#export LESS_TERMCAP_me="${sgr0}"
#export LESS_TERMCAP_se="${sgr0}"
#export LESS_TERMCAP_so="${bold}${smso}"
#export LESS_TERMCAP_ue="${sgr0}"
#export LESS_TERMCAP_us="${smul}"
#unset bold
#unset sgr0
#unset smso
#unset smul
#unset cyan

# vim:ft=sh
