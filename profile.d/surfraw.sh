# surfraw.sh: surfraw elvi paths

if command -v surfraw > /dev/null; then
  if test -d /usr/local/lib/surfraw; then
    export PATH="${PATH:+${PATH}:}/usr/local/lib/surfraw"
  fi
  if test -d /usr/lib/surfraw; then
    export PATH="${PATH:+${PATH}:}/usr/lib/surfraw"
  fi
  if test -d /lib/surfraw; then
    export PATH="${PATH:+${PATH}:}/lib/surfraw"
  fi
fi

# vim:ft=sh

