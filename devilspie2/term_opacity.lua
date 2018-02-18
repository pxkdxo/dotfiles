-- devilspie2 xterm/urxvt transparency

local string    = require("string")
local win_class = string.lower(get_window_class())

debug_print("Window Class : " .. win_class)

if string.find(win_class, "xterm") or string.find(win_class, "rxvt") then
  set_opacity(0.92)
end
