#!/usr/bin/env sh
# java.sh: java environment config

# Keep JAVA_HOME is it's already valid
if test -d "${JAVA_HOME:+${JAVA_HOME}/bin}"; then
  export JAVA_HOME
else
  # Otherwise try to find Java installation
  case "$(uname -s)" in
    [Dd]arwin*)
      # macOS - Prefer HOMEBREW_PREFIX (set by Homebrew), fallback to brew --prefix, java_home last
      if test -n "${HOMEBREW_PREFIX:-}" && test -d "${HOMEBREW_PREFIX}/opt/openjdk"; then
        export JAVA_HOME="${HOMEBREW_PREFIX}/opt/openjdk"
      elif command -v brew > /dev/null && JAVA_HOME="$(brew --prefix 2> /dev/null)/opt/openjdk" && test -d "${JAVA_HOME}"; then
        export JAVA_HOME
      elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/opt/openjdk"; then
        export JAVA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/opt/openjdk"
      elif test -d "${HOME}/.local/opt/homebrew/openjdk"; then
        export JAVA_HOME="${HOME}/.local/opt/homebrew/openjdk"
      elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/openjdk"; then
        export JAVA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/openjdk"
      elif test -d "/usr/local/share/homebrew/openjdk"; then
        export JAVA_HOME="/usr/local/share/homebrew/openjdk"
      elif test -d "/usr/local/opt/homebrew/openjdk"; then
        export JAVA_HOME="/usr/local/opt/homebrew/openjdk"
      elif test -d "/usr/share/homebrew/openjdk"; then
        export JAVA_HOME="/usr/share/homebrew/openjdk"
      elif test -d "/opt/homebrew/opt/openjdk"; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk"
      elif test -d "/usr/local/share/openjdk"; then
        export JAVA_HOME="/usr/local/share/openjdk"
      elif test -d "/usr/local/opt/openjdk"; then
        export JAVA_HOME="/usr/local/opt/openjdk"
      elif test -d "/usr/share/openjdk"; then
        export JAVA_HOME="/usr/share/openjdk"
      elif test -d "/opt/openjdk"; then
        export JAVA_HOME="/opt/openjdk"
      elif command -v /usr/libexec/java_home > /dev/null \
        && JAVA_HOME="$(/usr/libexec/java_home 2> /dev/null)"; then
        export JAVA_HOME
      else
        unset JAVA_HOME
      fi
      ;;
    [Ll]inux*)
      # linux - Check known locations and find the preferred or latest version
      if test -d "/usr/lib/jvm"; then
        if test -d "/usr/lib/jvm/default"; then
          JAVA_HOME="/usr/lib/jvm/default"
        else
          for directory in /usr/lib/jvm/java-*; do
            if test -d "${directory}"; then
              JAVA_HOME="${directory}"
            fi
          done
        fi
      elif test -d "/lib/jvm"; then
        if test -d "/lib/jvm/default"; then
          JAVA_HOME="/lib/jvm/default"
        else
          for directory in /lib/jvm/java-*; do
            if test -d "${directory}"; then
              JAVA_HOME="${directory}"
            fi
          done
        fi
      fi
      ;;
  esac
fi

# If we still have no home for Java...
if test -z "${JAVA_HOME-}" && command -v java > /dev/null; then
  if JAVA_HOME="$(command -v java)"; then
    JAVA_HOME="${JAVA_HOME%java}"
    JAVA_HOME="${JAVA_HOME%/}"
    JAVA_HOME="${JAVA_HOME%/bin}"
  fi
  if ! test -d "${JAVA_HOME}"; then
    unset JAVA_HOME
  fi
fi

# Export JAVA_HOME set to whichever path we found
if test -n "${JAVA_HOME-}" && test -d "${JAVA_HOME}/bin"; then
  export JAVA_HOME
  case ":${PATH}:" in
    *":${JAVA_HOME}/bin:"*) ;;
    *)
      export PATH="${JAVA_HOME}/bin${PATH:+:${PATH}}"
      ;;
  esac
else
  unset JAVA_HOME
fi

# vim:ft=sh
