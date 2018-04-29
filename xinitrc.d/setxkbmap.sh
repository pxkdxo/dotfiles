#!/usr/bin/env sh

## setxkbmap.sh
## configure the X11 keyboard map


/usr/bin/setxkbmap                \
  -layout us,us -variant mac,dvp  \
  -option                         \
  -option altwin:prtsc_rwin       \
  -option caps:escape             \
  -option grp:sclk_toggle         \
  -option grp_led:caps            \
  -option keypad:future_wang      \
  -option kpdl:dotoss             \
  -option kpdl:semi               \
  -option lv3:ralt_alt            \
  -option lv3:menu_switch         \
  -option nbsp:level3             \
  -option numpad:shift3           \
  -option shift:both_shiftlock    \
  -option terminate:ctrl_alt_bksp
