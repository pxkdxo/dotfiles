#
## Library to help configure the environment
#


## If given arguments, configure those variables.
## Otherwise, configure all variables.
function autoenv::main() {
  if (( $# )) || set -- BROWSER EDITOR GCC_COLORS LS_COLORS MANPAGER; then
    while (( $# )); do
      autoenv::"$1"
      shift
    done
  fi
}


## Set default browser
function autoenv::BROWSER() {
  local BROWSER='' && {
    case $# in
      1)
        declare -gx BROWSER="$1"
        ;;

      0)
        if [[ ${DISPLAY} ]]; then
          set -- google-chrome firefox chromium
        else
          set -- elinks w3m lynx
        fi
        ;&

      *)
        while (( $# )); do
          read -r BROWSER < <(command -v "$1") && {
            declare -gx BROWSER="$1"
            break
          }
          shift
        done
    esac
  }
}


## Set default text editor
function autoenv::EDITOR() {
  local EDITOR && {
    case $# in
      1)
        declare -gx EDITOR="$1"
        ;;

      0)
        set -- vim vi nano
        ;&

      *)
        while (( $# )); do
          read -r EDITOR < <(command -v "$1") && {
            declare -gx EDITOR="$1"
            break
          }
          shift
        done
    esac
  }
}


## Set GCC output formatting
function autoenv::GCC_COLORS() {
  declare -gx GCC_COLORS=\
"${*-"caret=01;34:error=01;31:locus=01;36:note=01;33:quote=01;32:warning=01;35"}"
}


## Set command output colors
function autoenv::LS_COLORS() {
  local LS_COLORS IFS && {
    if (( $# )); then
      IFS=:; declare -gx LS_COLORS="$*"
    elif command -v dircolors >/dev/null; then
      [[ -f ~/.dircolors ]] && set -- ~/.dircolors
      eval 'declare -gx '"$(command dircolors -b "$@")"
    else
      return 1
    fi
  }
}


## Set the pager command used by man
function autoenv::MANPAGER() {
  local MANPAGER && {
    if (( $# )); then
      declare -gx MANPAGER="$@"
    elif read -r  MANPAGER < <(command -v vim); then
      declare -gx MANPAGER="${MANPAGER@Q}"' -M +"set nonu nornu tw=0" +MANPAGER -'
    else
      return 1
    fi
  }
}



## Apply configuration
autoenv::main "$@"
