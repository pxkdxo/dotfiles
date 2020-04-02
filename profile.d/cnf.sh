# cnf.sh : command-not-found hooks for bash and zsh

# bash hook definition
command_not_found_handle()
{
  if test "$#" -gt 0
  then
    if command -v cnf-lookup > /dev/null
    then
      if test -t 1
      then
        cnf-lookup --colors -- "$1"
      else
        cnf-lookup -- "$1"
      fi
    else
      PATH=${PATH:+${PATH}:}/usr/local/lib:/usr/lib:/lib
      export PATH
      if command -v command-not-found > /dev/null
      then
        command-not-found -- "$1"
      else
        printf '%s: command not found\n' "$1"
      fi
      PATH=${PATH%/usr/local/lib:/usr/lib:/lib}
      PATH=${PATH%:}
      export PATH
    fi
  fi
  return 127
} >&2

# zsh hook definition
command_not_found_handler()
{
  if test "$#" -gt 0
  then
    if command -v cnf-lookup > /dev/null
    then
      if test -t 1
      then
        cnf-lookup --colors -- "$1"
      else
        cnf-lookup -- "$1"
      fi
    else
      PATH=${PATH:+${PATH}:}/usr/local/lib:/usr/lib:/lib
      export PATH
      if command -v command-not-found > /dev/null
      then
        command-not-found -- "$1"
      else
        printf '%s: command not found\n' "$1"
      fi
      PATH=${PATH%/usr/local/lib:/usr/lib:/lib}
      PATH=${PATH%:}
      export PATH
    fi
  fi
  return 127
} >&2

# vim:ft=sh
