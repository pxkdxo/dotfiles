#!/usr/bin/env sh
# java.sh: java environment config

# Keep JAVA_HOME if it's already valid
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
      # linux - prefer an explicit "default", else the highest-versioned JDK.
      # Glob order is lexical (java-9 > java-21, java-8 > java-17), so select
      # with version-sort semantics rather than keeping the last glob match.
      for jvm_root in /usr/lib/jvm /lib/jvm; do
        test -d "${jvm_root}" || continue
        if test -d "${jvm_root}/default"; then
          JAVA_HOME="${jvm_root}/default"
          break
        fi
        java_candidate="$(
          for directory in "${jvm_root}"/java-*; do
            test -d "${directory}" && printf '%s\n' "${directory}"
          done | sort -V | tail -n 1
        )"
        if test -n "${java_candidate}"; then
          JAVA_HOME="${java_candidate}"
          break
        fi
      done
      # Last resort: follow the distro's `java` alternative to its home.
      if test -z "${JAVA_HOME-}" && test -e /etc/alternatives/java; then
        java_alt="$(readlink -f /etc/alternatives/java 2> /dev/null)"
        java_alt="${java_alt%/bin/java}"
        test -d "${java_alt}/bin" && JAVA_HOME="${java_alt}"
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
