# zshenv: zsh user global initialization script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

if test -z "${PAGER}"; then
  if command -v pager > /dev/null; then
    export PAGER="pager"
  elif command -v bat > /dev/null; then
    export PAGER="bat"
  elif command -v less > /dev/null; then
    export PAGER="less"
  elif command -v nvimpager > /dev/null; then
    export PAGER="nvimpager"
  fi
fi
if test -z "${EDITOR}"; then
  if command -v editor > /dev/null; then
    export EDITOR="editor"
  elif command -v nvim > /dev/null; then 
    export EDITOR="nvim"
  elif command -v vim > /dev/null; then 
    export EDITOR="vim"
  elif command -v vi > /dev/null; then 
    export EDITOR="vi"
  fi
fi
if test -z "${VISUAL}"; then
  if command -v visual-editor > /dev/null; then
    export VISUAL="visual-editor"
  elif command -v visual > /dev/null; then
    export VISUAL="visual"
  elif command -v nvim > /dev/null; then 
    export VISUAL="nvim"
  elif command -v vim > /dev/null; then 
    export VISUAL="vim"
  fi
fi
if test -z "${BROWSER}"; then
  if command -v x-www-browser > /dev/null; then 
    export BROWSER=x-www-browser
  elif command -v "firefox" > /dev/null; then 
    export BROWSER="firefox"
  elif command -v "google-chrome" > /dev/null; then 
    export BROWSER="google-chrome"
  fi
fi

# vi:ft=zsh
