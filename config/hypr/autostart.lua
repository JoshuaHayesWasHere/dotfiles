-- Processes started once with the session.
local SCRIPTS = CONFIG_DIR .. "/scripts/"

-- True when this Hyprland has no physical output: it runs as a window inside
-- another compositor, or headless.
local function nested()
    for _, monitor in ipairs(hl.get_monitors()) do
        local name = monitor.name
        if not (name:match("^WAYLAND%-") or name:match("^HEADLESS%-") or name == "FALLBACK") then
            return false
        end
    end
    return true
end

hl.on("hyprland.start", function()
    -- Wallpaper and shell (bar, overview) belong to this compositor instance.
    hl.exec_cmd("awww-daemon --format xrgb")
    hl.exec_cmd(SCRIPTS .. "wallpaper restore")
    for _, output in ipairs({ "dp2", "dp3", "dp1" }) do
        hl.exec_cmd("waybar -c $HOME/.config/waybar/per-monitor/" .. output .. ".jsonc")
    end
    hl.exec_cmd("qs")

    -- Everything below is per user, not per compositor. A nested test run
    -- must not repeat it: the environment import would point the real
    -- session's services at the nested socket.
    if nested() then return end

    -- Let systemd user units and D-Bus services see the Wayland session.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("systemctl --user start voxtype") -- dictation daemon (SUPER + V)
    hl.exec_cmd("dictation warm") -- load its punctuation model before the first dictation
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")

    -- Clipboard history.
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
