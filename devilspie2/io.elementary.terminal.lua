-- devilspie2/xterm.lua : Apply transparency to XTerm windows

debug_print("application    : " .. get_application_name())
debug_print("window class   : " .. get_window_class())
debug_print("class instance : " .. get_class_instance_name())
debug_print("")

-- Set window opacity
if get_window_class() == "Io.elementary.terminal" then
  set_window_opacity(0.95)
end

-- End of Script
