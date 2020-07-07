# less.sh : less environment config
# see less(1)

# Default options
export LESS='-FgiMqRX-2'

# Non-printable character representation
export LESSBINFMT='*d<%02x>'

# Non-printable character representation (utf-8)
export LESSUTFBINFMT='<U+%04lx>'

## Enable text attributes
#if LESS_TERMCAP_mb="$(tput sitm)"; then
#  export LESS_TERMCAP_mb
#fi
#if LESS_TERMCAP_md="$(tput bold)"; then
#  export LESS_TERMCAP_md
#fi
#if LESS_TERMCAP_me="$(tput sgr0)"; then
#  export LESS_TERMCAP_me
#fi
#if LESS_TERMCAP_se="$(tput rmso)"; then
#  export LESS_TERMCAP_se
#fi
#if LESS_TERMCAP_so="$(tput smso)"; then
#  export LESS_TERMCAP_so
#fi
#if LESS_TERMCAP_us="$(tput smul)"; then
#  export LESS_TERMCAP_us
#fi
#if LESS_TERMCAP_ue="$(tput rmul)"; then
#  export LESS_TERMCAP_ue
#fi

# vim:ft=sh
