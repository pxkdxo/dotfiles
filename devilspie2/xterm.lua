--[[
  devilspie2/xterm.lua
  Apply transparency to XTerm windows
--]]

debug_print("application    : " .. get_application_name())
debug_print("window class   : " .. get_window_class())
debug_print("class instance : " .. get_class_instance_name())
debug_print("")

if get_window_class() == "XTerm" then
  if get_class_instance_name() == "QuakeDD" then
    set_window_opacity(0.85)
  else
    set_window_opacity(0.90)
  end
end
