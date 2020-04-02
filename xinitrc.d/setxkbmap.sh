#!/usr/bin/env sh
#
# Set X keymap layout and options

setxkbmap -layout us
# setxkbmap -variant mac
setxkbmap -option
setxkbmap -option terminate:ctrl_alt_bksp
# setxkbmap -option shift:breaks_caps
# setxkbmap -option numpad:shift3
# setxkbmap -option lv3:rwin_switch
# setxkbmap -option lv3:menu_switch
# setxkbmap -option kpdl:semi
# setxkbmap -option kpdl:dotoss
# setxkbmap -option keypad:future_wang
# setxkbmap -option grp_led:caps
# setxkbmap -option grp:caps_toggle
# setxkbmap -option caps:super
# setxkbmap -option caps:shiftlock
setxkbmap -option caps:escape
# setxkbmap -option caps:ctrl_modifier
# setxkbmap -option altwin:prtsc_rwin
# setxkbmap -option altwin:hyper_win

# vi:ft=sh
