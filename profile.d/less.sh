# less.sh : less environment config
# see less(1)


# Default options
export LESS="${LESS:--FgiMqRX --window=-2}"

# Non-printable character representation
export LESSBINFMT="${LESSBINFMT:-*d<%02x>}"

# Non-printable character representation (utf-8)
export LESSUTFBINFMT="${LESSUTFBINFMT:-<U+%04lx>}"

# Characters that may end a video escape sequence
export LESSANSIENDCHARS="${LESSANSIENDCHARS:-m}"

# Characters that may compose a video escape sequence
export LESSANSIMIDCHARS="${LESSANSIMIDCHARS:-"B0123456789:;[?!\"\'#%()*+ "}"

# vim:ft=sh
