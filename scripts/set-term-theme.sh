#!/bin/sh
# set-term-theme.sh [light|dark|auto|--watch] — point each terminal's `default.theme`
# symlink at the light or dark variant and reload running instances.
#
#   light | dark   force a variant
#   auto           follow the system appearance, else time of day (default)
#   --watch        apply auto now, then re-apply on every GNOME color-scheme
#                  change (Linux; needs gsettings). Used by theme-watch.service.
#
# Each app keeps the convention:
#   <app>/default.theme.EXT -> {light,dark}.theme.EXT -> colorschemes/<theme>.EXT
# so switching is just re-pointing default.theme.EXT. This is the upstream
# driver: once the terminal re-themes, the shell's OSC detection (see
# detect-term-bg.sh) carries light/dark on to vivid, starship, and tmux.
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

# Resolve light/dark from the system, else time of day.
detect_variant() {
  if [ "$(uname)" = Darwin ]; then
    # AppleInterfaceStyle is "Dark" in dark mode and unset in light mode.
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
      echo dark
    else
      echo light
    fi
    return
  fi
  if command -v gsettings > /dev/null 2>&1; then
    case "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" in
      *prefer-dark*)              echo dark;  return ;;
      *prefer-light* | *default*) echo light; return ;;
    esac
  fi
  # No system signal: daytime is light, night is dark.
  hour="$(date +%H)"
  if [ "$hour" -ge 7 ] && [ "$hour" -lt 19 ]; then
    echo light
  else
    echo dark
  fi
}

# Watch mode: apply once, then follow GNOME appearance changes.
if [ "${1:-}" = --watch ]; then
  if ! gsettings get org.gnome.desktop.interface color-scheme > /dev/null 2>&1; then
    echo "${0##*/}: --watch needs the GNOME color-scheme gsetting" >&2
    exit 1
  fi
  "$0" auto || true
  gsettings monitor org.gnome.desktop.interface color-scheme | while read -r _; do
    "$0" auto || true
  done
  exit 0
fi

variant="${1:-auto}"
case "$variant" in
  light | dark) ;;
  auto) variant="$(detect_variant)" ;;
  *) echo "usage: ${0##*/} [light|dark|auto|--watch]" >&2; exit 64 ;;
esac

# Re-point one app's selector, only when it actually changes. Sets `changed`
# so we reload terminals just once, and never when already on the variant.
# $1 = app config subdir, $2 = file extension.
changed=0
repoint() {
  dir="$config_home/$1"
  [ -d "$dir" ] && [ -e "$dir/${variant}.theme.$2" ] || return 0
  link="$dir/default.theme.$2"
  [ "$(readlink "$link" 2>/dev/null)" = "${variant}.theme.$2" ] && return 0
  ln -sf "${variant}.theme.$2" "$link"
  changed=1
}

repoint alacritty toml
repoint foot      ini
repoint kitty     conf

# Reload only if something changed. alacritty live-reloads on file change;
# foot and kitty reload their config on SIGUSR1.
if [ "$changed" -eq 1 ]; then
  for app in foot kitty; do
    pkill -USR1 -x "$app" 2>/dev/null || true
  done
fi

echo "theme: $variant"
