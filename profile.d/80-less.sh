#!/usr/bin/env sh
# less.sh: less environment config
# see less(1)

# Default options
export LESS='-FiQRSX --mouse'

# Non-printable character representation
export LESSBINFMT='*d<%02x>'

# Non-printable character representation (utf-8)
export LESSUTFBINFMT='<U+%04lx>'

# Enable colorization
if command -v bat > /dev/null; then
  export LESSCOLORIZER='bat --style=plain --color=always'
elif command -v pygmentize > /dev/null; then
  export LESSCOLORIZER='pygmentize -O' # -P allowed as well
elif command -v source-highlight > /dev/null; then
  export LESSCOLORIZER='source-highlight'
elif command -v nvimpager > /dev/null; then
  export LESSCOLORIZER='nvimpager -c'
elif command -v vimcolor > /dev/null; then
  export LESSCOLORIZER='vimcolor'
fi

# Use lesspipe.sh pre-processor
# if command -v lesspipe.sh > /dev/null; then
#   export LESSOPEN='lesspipe.sh %s'
# else
#   unset LESSOPEN
# fi

# vim:ft=sh
