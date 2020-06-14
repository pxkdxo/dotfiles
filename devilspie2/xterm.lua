-- devilspie2/xterm.lua : Apply transparency to xterm windows

debug_print("application    : " .. get_application_name())
debug_print("window class   : " .. get_window_class())
debug_print("class instance : " .. get_class_instance_name())
debug_print("")

local os = os

-- Set window opacity
if get_window_class() == "XTerm" then
    --[[ QuakeDD dropdown terminal
    if get_class_instance_name() == "QuakeDD" then
        set_window_opacity(0.88)
    end
    --]]
    set_window_opacity(tonumber(
    os.getenv('XTERM_WINDOW_OPACITY') or
    os.getenv('TERM_WINDOW_OPACITY') or "0.92"))
end
