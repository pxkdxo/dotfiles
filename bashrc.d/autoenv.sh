#
## Library to help configure the environment
#


## If given arguments, configure those variables.
## Otherwise, configure all variables.
function autoenv::main() {
  if (( $# )) || set -- BROWSER EDITOR GCC_COLORS LS_COLORS; then
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
          set -- w3m elinks lynx
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
  if local IFS LS_COLORS='' \
    && \command -v dircolors
  then
    case "$(($#))" in
      0)
        if [[ -f ~/.dircolors ]]; then
          IFS=\' read -r _ LS_COLORS _ < <(\command dircolors -b ~/.dircolors)
          declare -gx LS_COLORS=${LS_COLORS}
          return $?
        else
          IFS=\' read -r _ LS_COLORS _ < <(\command dircolors -b)
          declare -gx LS_COLORS=${LS_COLORS}
          return $?
        fi
        ;;
      1)
        if [[ -f $1 ]]; then
          IFS=\' read -r _ LS_COLORS _ < <(\command dircolors -b "$1")
          declare -gx LS_COLORS=${LS_COLORS}
          return $?
        else
          return $?
        fi
        ;;
      *)
        IFS=:
        declare -gx LS_COLORS="$*"
        return $?
        ;;
    esac
  fi >/dev/null
}



## Apply configuration
autoenv::main "$@"
