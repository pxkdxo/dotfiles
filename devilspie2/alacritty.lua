-- devilspie2/alacritty.lua : apply transparency to alacritty windows

debug_print("application    : " .. get_application_name())
debug_print("window class   : " .. get_window_class())
debug_print("class instance : " .. get_class_instance_name())
debug_print("")

-- Set window opacity
if get_window_class() == "Alacritty" then
    set_window_opacity(tonumber(
    os.getenv('ALACRITTY_WINDOW_OPACITY') or
    os.getenv('TERM_WINDOW_OPACITY') or "0.98"))
end
-- ]]
