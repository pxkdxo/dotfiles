## manpager.sh : set MANPAGER

## Set the command for viewing man pages

## Use neovim to view man pages
if command -v nvim 1>/dev/null; then
  MANPAGER='nvim -c '"'"'set ft=man'"'"' -'
  export MANPAGER

## Use vim to view man pages
elif command -v vim 1>/dev/null; then
  MANPAGER='vim -M -n -c '"'"'MANPAGER'"'"' -'
  export MANPAGER

fi
