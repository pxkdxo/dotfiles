# less.sh : environment configuration for less


# Default options
export LESS="${LESS:--FgiMqRX --window=-2}"

# Format for non-printable, non-control characters
export LESSBINFMT="${LESSBINFMT:-*d<%02x>}"

# Format for non-printable, non-control characters (utf-8)
export LESSUTFBINFMT="${LESSUBINFMT:-<U+%04lx>}"

# Characters that are allowed to end a video escape sequence
export LESSANSIENDCHARS="${LESSANSIENDCHARS:-m}"

# Characters that are allowed within a video escape sequence
export LESSANSIMIDCHARS="${LESSANSIMIDCHARS:-B0123456789:;[?!\"\'#%()*+ }"

# Set video attribute escapes if the tput command is available
if command -v tput 1> /dev/null
then
    ## Enter blink mode
    #if LESS_TERMCAP_mb="$(tput blink)"
    #then
    #    export LESS_TERMCAP_mb
    #else
    #    unset -v LESS_TERMCAP_mb
    #fi
    # Enter bold mode
    if LESS_TERMCAP_md="$(tput bold)"
    then
        export LESS_TERMCAP_md
    else
        unset -v LESS_TERMCAP_md
    fi
    # End all video attributes
    if LESS_TERMCAP_me="$(tput sgr0)"
    then
        export LESS_TERMCAP_me
    else
        unset -v LESS_TERMCAP_me
    fi
    # Enter standout mode
    if LESS_TERMCAP_so="$(tput smso)"
    then
        export LESS_TERMCAP_so
    else
        unset -v LESS_TERMCAP_so
    fi
    # End standout mode
    if LESS_TERMCAP_se="$(tput rmso)"
    then
        export LESS_TERMCAP_se
    else
        unset -v LESS_TERMCAP_se
    fi
    # Enter underline mode
    if LESS_TERMCAP_us="$(tput smul)"
    then
        export LESS_TERMCAP_us
    else
        unset -v LESS_TERMCAP_us
    fi
    # End underline mode
    if LESS_TERMCAP_ue="$(tput rmul)"
    then
        export LESS_TERMCAP_ue
    else
        unset -v LESS_TERMCAP_ue
    fi
    # Enter reverse-video mode
    if LESS_TERMCAP_mr="$(tput rev)"
    then
        export LESS_TERMCAP_mr
    else
        unset -v LESS_TERMCAP_mr
    fi
    # Enter dim mode
    if LESS_TERMCAP_mh="$(tput dim)"
    then
        export LESS_TERMCAP_mh
    else
        unset -v LESS_TERMCAP_mh
    fi
    # Enter subscript mode
    if LESS_TERMCAP_ZN="$(tput ssubm)"
    then
        export LESS_TERMCAP_ZN
    else
        unset -v LESS_TERMCAP_ZN
    fi
    # End subscript mode
    if LESS_TERMCAP_ZV="$(tput rsubm)"
    then
        export LESS_TERMCAP_ZV
    else
        unset -v LESS_TERMCAP_ZV
    fi
    # Enter superscript mode
    if LESS_TERMCAP_ZO="$(tput ssupm)"
    then
        export LESS_TERMCAP_ZO
    else
        unset -v LESS_TERMCAP_ZO
    fi
    # End superscript mode
    if LESS_TERMCAP_ZW="$(tput rsupm)"
    then
        export LESS_TERMCAP_ZW
    else
        unset -v LESS_TERMCAP_ZW
    fi
fi 2>/dev/null


# vim:ft=sh
