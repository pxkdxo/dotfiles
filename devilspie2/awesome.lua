-- Support Awesome 3.5 WM

local posix = require("posix");
local os    = require("os");

local awesome = "/usr/bin/awesome-client"
if not posix.stat(awesome, "type") == "file" then
  awesome = nil;
end

-- Check for tiling mode
function is_tiling()
  if awesome then
    return true;
  end
  return false;
end

-- Make window floating
-- Parameters: state - true to make window floating, else make window tiled
function set_tile_floating( state )
  if not awesome then
    return nil;
  end

  if state then state = "true" else state = "false" end

  local xid = get_window_xid();

  local command = awesome .. [[
local naughty = require("naughty");
local awcl    = require("awful.client");
local client  = require("client");

for k, c in pairs(client.get()) do
  if c.window == " .. xid .. " then
    awcl.floating.set(c, " .. state .. ");
  end
end
]];

  debug_print("Awesome Floating Client: " .. command);
  return os.execute(command);
end
