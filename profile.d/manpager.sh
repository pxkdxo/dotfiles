# manpager.sh : manual pager configuration

# Use vim or nvim if availabe
if command -v nvim > /dev/null
then
  export MANPAGER="nvim -c 'set ft=man' -"
elif command -v vim > /dev/null
then
  export MANPAGER="vim -M -c MANPAGER -"
fi

# vim:ft=sh
