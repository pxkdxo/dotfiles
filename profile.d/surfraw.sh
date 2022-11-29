#!/usr/bin/env sh
# surfraw.sh: surfraw elvi path config

if command -v surfraw > /dev/null; then
  if test -d /usr/local/lib/surfraw; then
    case  ":${PATH}:" in
      *:"/usr/local/lib/surfraw":*) ;;
      *) export PATH="${PATH:+${PATH}:}/usr/local/lib/surfraw" ;;
    esac
  elif test -d /usr/lib/surfraw; then
    case ":${PATH}:" in
      *:"/usr/lib/surfraw":*) ;;
      *) export PATH="${PATH:+${PATH}:}/usr/lib/surfraw" ;;
    esac
  elif test -d /lib/surfraw; then
    case ":${PATH}:" in
      *:"/lib/surfraw":*) ;;
      *) export PATH="${PATH:+${PATH}:}/lib/surfraw" ;;
    esac
  fi
fi

# vim:ft=sh

