#!/usr/bin/env sh

## Set the X keymap layout and unset any options
setxkbmap -layout us,us -variant ,dvp -option

## Set preferred X keymap options
setxkbmap -option altwin:prtsc_rwin \
          -option caps:shiftlock \
          -option grp:sclk_toggle \
          -option grp_led:scroll \
          -option keypad:future_wang \
          -option kpdl:dotoss \
          -option kpdl:semi \
          -option lv3:ralt_alt \
          -option lv3:menu_switch \
          -option numpad:shift3 \
          -option shift:breaks_caps \
          -option terminate:ctrl_alt_bksp
