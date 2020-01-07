# manpager.sh : manual pager configuration

# Use vim or nvim if availabe
if command -v nvim 1> /dev/null
then
  export MANPAGER="nvim -c 'set ft=man' -"
elif command -v vim 1> /dev/null
then
  export MANPAGER="vim -M -c MANPAGER -"
fi

# vim:ft=sh
