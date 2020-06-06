-- devilspie2/urxvt.lua : Apply transparency to URxvt windows

debug_print("application    : " .. get_application_name())
debug_print("window class   : " .. get_window_class())
debug_print("class instance : " .. get_class_instance_name())
debug_print("")

-- Set window opacity
if get_window_class() == "URxvt" then
    --[[ QuakeDD dropdown terminal
    if get_class_instance_name() == "QuakeDD" then
        set_window_opacity(0.88)
    end
    --]]
    set_window_opacity(tonumber(
    os.getenv('RXVT_WINDOW_OPACITY') or os.getenv('TERM_WINDOW_OPACITY') or "0.92"))
end
