#!/usr/bin/env sh
# java.sh: java environment config

# Check if JAVA_HOME is already set and valid
if test -n "${JAVA_HOME:-}" && test -d "${JAVA_HOME}/bin"; then
  export JAVA_HOME
  return 0
fi

# Try to find Java installation
case "$(uname)" in
  Darwin)
    # macOS: Check common Homebrew locations
    if test -d "/opt/homebrew/opt/openjdk"; then
      JAVA_HOME="/opt/homebrew/opt/openjdk"
    elif test -d "/usr/local/opt/openjdk"; then
      JAVA_HOME="/usr/local/opt/openjdk"
    elif command -v /usr/libexec/java_home > /dev/null; then
      JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
    fi
    ;;
  Linux)
    # Linux: Check common locations
    if test -d "/lib/jvm/default"; then
      JAVA_HOME="/lib/jvm/default"
    elif test -d "/usr/lib/jvm/default"; then
      JAVA_HOME="/usr/lib/jvm/default"
    elif test -d "/lib/jvm"; then
      # Find the latest Java version
      for directory in /lib/jvm/java-*; do
        if test -d "${directory}"; then
          JAVA_HOME="${directory}"
        fi
      done
    elif test -d "/usr/lib/jvm"; then
      for directory in /usr/lib/jvm/java-*; do
        if test -d "${directory}"; then
          JAVA_HOME="${directory}"
        fi
      done
    fi
    ;;
esac

# Try to find Java via command
if test -z "${JAVA_HOME:-}" && command -v java > /dev/null; then
  java_path="$(command -v java)"
  # Resolve symlinks and get directory
  if test -L "${java_path}"; then
    java_path="$(readlink -f "${java_path}" 2>/dev/null || readlink "${java_path}" 2>/dev/null || echo "${java_path}")"
  fi
  # Remove /bin/java to get JAVA_HOME
  JAVA_HOME="${java_path%/*/java}"
  if test "${JAVA_HOME}" = "${java_path}"; then
    JAVA_HOME="${java_path%/bin/java}"
  fi
  unset java_path
fi

# Export JAVA_HOME if found and valid
if test -n "${JAVA_HOME:-}" && test -d "${JAVA_HOME}/bin"; then
  export JAVA_HOME
  # Add to PATH if not already present
  case ":${PATH}:" in
    *":${JAVA_HOME}/bin:"*) ;;
    *) export PATH="${PATH:+${PATH}:}${JAVA_HOME}/bin" ;;
  esac
fi

# vim:ft=sh
