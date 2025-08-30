#!/usr/bin/env sh
# java.sh: java environment config

if test -d /lib/jvm/default
then
  JAVA_HOME="/lib/jvm/default"
elif test -d /lib/jvm
then
  for directory in /lib/jvm/java-*
  do
    if test -d "${directory}"
    then
      JAVA_HOME="${directory}"
    fi
  done
fi
if test -n "${JAVA_HOME}"
then
  export JAVA_HOME
fi

# vim:ft=sh
