#!/usr/bin/env bash
# extract_palette.sh NAME
# shellcheck shell=bash


__extract_palette_short_doc() {
  cat
  return "$((${1-0}))"
} << EOF
Find and scan different versions of a colorscheme to make a palette.
EOF


__extract_palette_usage() {
  cat
  return "$((${1-0}))"
} << EOF
usage: ${0##*/} COLORSCHEME_NAME [COLORSCHEME_NAME ...]
EOF


__extract_palette_help() {
  __extract_palette_short_doc
  __extract_palette_usage
  return "$((${1-0}))"
}


extract_palette() {
  local class_group='(bright_|light_|dark_|dim_|cursor_|selection_|highlight_|text_|foreground_|background_|fg_|bg_)'
  local color_group='(foreground|background|fg|bg|red|green|blue|yellow|purple|pink|cyan|magenta|teal|tan|orange|brown|black|white|gr[ae]y)'
  local alter_group='(_alt|_[0-9]+)'
  local affix_group='(colou?r)'
  local quote_class="[\"']"
  local hexno_group='[#0]?x?([[:xdigit:]]{6})'
  local sub_pattern="^${quote_class}?_?${affix_group}?_?(${class_group}?${color_group}${alter_group}*)_?${affix_group}?_?${quote_class}?_*=_*${quote_class}?${hexno_group}${quote_class}?$"
  local sub_replace='\2 = "#\7"'
  local search_re=""
  local filter_re="[[:graph:]].*[=:].*${quote_class}?${hexno_group}${quote_class}?"
  local directory=""
  local put_nl=0
  local result=""
  local colors=""
  for colors in "$@"; do
    case "${colors}" in
      */*)
        directory="${colors%/*}"
        colors="${colors##*/}"
        ;;
      *)
        directory="${XDG_CONFIG_HOME:-${HOME}/.config}/colorschemes"
        ;;
    esac
    search_re="${directory}/.*/${colors//[ _-]/[ _-]}\([.][a-z0-9_-][a-z0-9_-]*\)*"
    if result=$(
      find -L "${directory}"/ -mindepth 2 -type f -iregex "${search_re}" -exec \
        grep -E -I --ignore-case --no-filename --only-matching "${filter_re}" '{}' + |
        LC_ALL=C tr -- ':[:upper:][:blank:]-' '=[:lower:]_' |
        sed -E -n "s/${sub_pattern}/${sub_replace}/p" |
        sed -E -e 's/^fg/foreground/' -e 's/^bg/background/' -e 's/_foreground/_fg/' -e 's/_background/_bg/' |
        sort -u --field-separator '=' --key '1,1b'
      ) && test -n "${result}"
    then
      if test "${put_nl}" -eq 0; then
        put_nl=1
      else
        echo
      fi
      colors="${colors//[[:blank:][:cntrl:][:punct:]]/_}"
      printf '%b>>>%b %b%s%b\n' '\e[0;1m' '\e[0m' '\e[1;4m' "${colors}.palette.toml" '\e[0m'
      printf '[palette."%s"]\n%s\n' "${colors}" "${result}" | tee "${colors}.palette.toml"
    fi
  done
}


if test "$#" -gt 0; then
  extract_palette "$@"
else
  >&2 __extract_palette_help 2
fi
