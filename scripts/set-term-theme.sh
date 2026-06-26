#!/bin/sh
# set-term-theme.sh [light|dark|auto|--watch] — point each terminal's `default.theme`
# symlink at the light or dark variant and reload running instances.
#
#   light | dark   force a variant
#   auto           follow the system appearance, else time of day (default)
#   --watch        apply auto now, then re-apply on every GNOME color-scheme
#                  change (Linux; needs gsettings). Used by theme-watch.service.
#
# alacritty and kitty follow the symlink-selector convention:
#   <app>/default.theme.EXT -> {light,dark}.theme.EXT -> colorschemes/<theme>.EXT
# switching = re-point default.theme.EXT (alacritty live-reloads; kitty on
# SIGUSR1). foot is different: it has no config reload, but switches between its
# own [colors-dark]/[colors-light] sections live on SIGUSR1 (dark) / SIGUSR2
# (light), so it needs no symlink — just the signal.
#
# Upstream driver: the shell's OSC detection (detect-term-bg.sh) carries the
# change downstream to vivid, starship, and tmux.
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

# Publish the active variant so live shells can follow it (zshrc reads this each
# prompt and re-themes on change). XDG_CACHE_HOME, with a ~/.cache fallback.
theme_file="${XDG_CACHE_HOME:-$HOME/.cache}/term-theme.txt"
mkdir -p -- "${theme_file%/*}"
printf '%s\n' "$variant" > "$theme_file" 2>/dev/null || true

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
repoint kitty     conf

# kitty reloads its config (and the symlink we just repointed) on SIGUSR1 —
# only nudge it when something changed. alacritty live-reloads on file change.
if [ "$changed" -eq 1 ]; then
  pkill -USR1 -x kitty 2>/dev/null || true
fi

# foot switches between its own [colors-dark]/[colors-light] sections live:
# SIGUSR1 -> dark, SIGUSR2 -> light. No symlink, no reload. Safe no-op when
# foot is not running; its trigger is event-driven, so this never spams.
if [ "$variant" = light ]; then
  pkill -USR2 -x foot 2>/dev/null || true
else
  pkill -USR1 -x foot 2>/dev/null || true
fi

echo "theme: $variant"
