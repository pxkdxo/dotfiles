# less.sh : less environment config
# see less(1)

export LESS='-FgiMqRX-2'
# Non-printable character representation
export LESSBINFMT='*d<%02x>'
# Non-printable character representation (utf-8)
export LESSUTFBINFMT='<U+%04lx>'

# support video attributes
#LESS_TERMCAP_mb="$(tput bold)" && export LESS_TERMCAP_mb
#LESS_TERMCAP_md="$(tput sitm)" && export LESS_TERMCAP_md
#LESS_TERMCAP_me="$(tput sgr0)" && export LESS_TERMCAP_me
#LESS_TERMCAP_se="$(tput sgr0)" && export LESS_TERMCAP_se
#LESS_TERMCAP_so="$(tput smso)" && export LESS_TERMCAP_so
#LESS_TERMCAP_ue="$(tput rmul)" && export LESS_TERMCAP_ue
#LESS_TERMCAP_us="$(tput smul)" && export LESS_TERMCAP_us

# vim:ft=sh
