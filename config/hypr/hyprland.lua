-- Hyprland entry point. Each concern lives in its own module beside this file.
--
-- CONFIG_DIR is resolved from this file's own location rather than hardcoded,
-- so the tree works from any path (it is developed side by side with the old
-- config before taking over ~/.config/hypr).
CONFIG_DIR = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$")
package.path = CONFIG_DIR .. "/?.lua;" .. package.path

-- monitors.lua is written by nwg-displays; leave it generated.
dofile(CONFIG_DIR .. "/monitors.lua")

require("settings")
require("workspaces")
require("rules")
require("binds")
require("autostart")
