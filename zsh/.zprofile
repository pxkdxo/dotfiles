# zprofile: login shell initialization script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)


# Load login shell config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  source ~/.profile
fi

# vi:ft=zsh

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# added by Snowflake SnowSQL installer v1.2
export PATH=/Users/patrick.deyoreo/Applications/SnowSQL.app/Contents/MacOS:$PATH
