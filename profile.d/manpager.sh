# manpager.sh : manual pager configuration

# Use vim or nvim if availabe
if command -v nvim; then
  export MANPAGER='nvim +Man!'
elif command -v vim; then
  export MANPAGER='vim -M +MANPAGER -'
fi > /dev/null

# vim:ft=sh
