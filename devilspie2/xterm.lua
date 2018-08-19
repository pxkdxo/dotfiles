-- devilspie2/xterm.lua : Apply transparency to XTerm windows

debug_print("application    : " .. get_application_name())
debug_print("window class   : " .. get_window_class())
debug_print("class instance : " .. get_class_instance_name())
debug_print("")

-- Set xterm window opacity
if get_window_class() == "XTerm" then

  -- QuakeDD (dropdown terminal)
  if get_class_instance_name() == "QuakeDD" then
    set_window_opacity(0.80)

  -- Default
  else
    set_window_opacity(0.90)

  end

end

-- End of Script
