-- Keybinds. Every bind carries a description; scripts/keybinds turns those into
-- the cheat sheet (Super+Shift+K), so the two can never drift apart.
local workspaces = require("workspaces")

local SCRIPTS = CONFIG_DIR .. "/scripts/"
local TERMINAL = "kitty"
local FILES = "thunar"

local function bind(keys, action, description, opts)
    opts = opts or {}
    opts.description = description
    return hl.bind(keys, action, opts)
end

local function run(command)
    return hl.dsp.exec_cmd(command)
end

local function script(name)
    return hl.dsp.exec_cmd(SCRIPTS .. name)
end

-- Applications ----------------------------------------------------------------
bind("SUPER + Return", run(TERMINAL), "Terminal")
bind("SUPER + SHIFT + Return", run(TERMINAL .. " zsh -ic fm"), "Terminal attached to the firstmate tmux session")
bind("SUPER + E", run(FILES), "File manager")
bind("SUPER + B", run('xdg-open "https://"'), "Browser")
bind("SUPER + D", run("pkill rofi || rofi -show drun -modi drun,filebrowser,run,window"), "App launcher")
bind("SUPER + A", hl.dsp.global("quickshell:overviewToggle"), "Workspace overview")
bind("SUPER + ALT + V", script("clipboard"), "Clipboard history")
bind("SUPER + SHIFT + K", script("keybinds"), "Keybind cheat sheet")
bind("SUPER + End", script("wallpaper pick"), "Pick a wallpaper")
bind("CTRL + ALT + W", script("wallpaper random"), "Random wallpaper")

-- Session ---------------------------------------------------------------------
bind("CTRL + ALT + L", run("loginctl lock-session"), "Lock the screen")
bind("SUPER + SHIFT + N", run("swaync-client -t -sw"), "Notification centre")
bind("CTRL + ALT + Delete", hl.dsp.exit(), "Exit Hyprland")
bind("XF86Sleep", run("systemctl suspend"), "Suspend", { locked = true })

bind("CTRL + ALT + P", script("powermenu"), "Power menu")

-- Windows ---------------------------------------------------------------------
bind("SUPER + Q", hl.dsp.window.close(), "Close window")
bind("SUPER + SHIFT + Q", function()
    local window = hl.get_active_window()
    if window then hl.exec_cmd("kill " .. window.pid) end
end, "Terminate the window's process")
bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
-- Enter without letting go of Super, to send a message straight after dictating.
bind("SUPER + SPACE", hl.dsp.send_shortcut({ mods = "", key = "Return" }), "Press Enter")
bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximise")
bind("SUPER + P", hl.dsp.window.pseudo(), "Pseudo-tile")
bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, "Next window")

local directions = {
    { key = "h", arrow = "left", dir = "left" },
    { key = "j", arrow = "down", dir = "down" },
    { key = "k", arrow = "up", dir = "up" },
    { key = "l", arrow = "right", dir = "right" },
}
for _, d in ipairs(directions) do
    bind("SUPER + " .. d.key, hl.dsp.focus({ direction = d.dir }), "Focus " .. d.dir)
    bind("SUPER + " .. d.arrow, hl.dsp.focus({ direction = d.dir }), "Focus " .. d.dir)
    bind("SUPER + CTRL + " .. d.key, hl.dsp.window.move({ direction = d.dir }), "Move window " .. d.dir)
    bind("SUPER + ALT + " .. d.arrow, hl.dsp.window.swap({ direction = d.dir }), "Swap with window " .. d.dir)
end

local STEP = 50
for arrow, delta in pairs({ left = { -STEP, 0 }, right = { STEP, 0 }, up = { 0, -STEP }, down = { 0, STEP } }) do
    bind("SUPER + SHIFT + " .. arrow, hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }),
        "Resize window " .. arrow, { repeating = true })
end

bind("SUPER + mouse:272", hl.dsp.window.drag(), "Drag window", { mouse = true })
bind("SUPER + mouse:273", hl.dsp.window.resize(), "Resize window with the mouse", { mouse = true })

-- Layout ----------------------------------------------------------------------
bind("SUPER + ALT + L", function()
    local next_layout = hl.get_config("general.layout") == "dwindle" and "master" or "dwindle"
    hl.config({ general = { layout = next_layout } })
    hl.notification.create({ text = next_layout .. " layout", timeout = 1500 })
end, "Toggle dwindle / master layout")
bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit"), "Dwindle: flip the split")
bind("SUPER + I", hl.dsp.layout("addmaster"), "Master: add a master")
bind("SUPER + CTRL + D", hl.dsp.layout("removemaster"), "Master: remove a master")
bind("SUPER + CTRL + Return", hl.dsp.layout("swapwithmaster"), "Master: swap with master")

-- Workspaces ------------------------------------------------------------------
for i = 1, 10 do
    local key = "code:" .. (9 + i) -- the number row by keycode, so layout does not matter
    bind("SUPER + " .. key, function() workspaces.focus(i) end, "Workspace " .. i .. " on this monitor")
    bind("SUPER + SHIFT + " .. key, function() workspaces.move(i, true) end, "Move window to workspace " .. i)
    bind("SUPER + CTRL + " .. key, function() workspaces.move(i, false) end, "Send window to workspace " .. i .. " and stay")
end

bind("SUPER + Tab", hl.dsp.focus({ workspace = "m+1" }), "Next workspace on this monitor")
bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), "Previous workspace on this monitor")
bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" }), "Next occupied workspace")
bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" }), "Previous occupied workspace")
bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next occupied workspace")
bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous occupied workspace")
bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ workspace = "r+1" }), "Move window to the next workspace")
bind("SUPER + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "r-1" }), "Move window to the previous workspace")
bind("SUPER + CTRL + bracketright", hl.dsp.window.move({ workspace = "r+1", follow = false }), "Send window to the next workspace")
bind("SUPER + CTRL + bracketleft", hl.dsp.window.move({ workspace = "r-1", follow = false }), "Send window to the previous workspace")

-- Monitors --------------------------------------------------------------------
bind("SUPER + SHIFT + M", workspaces.swap_with_next_monitor, "Swap windows with the next monitor")
bind("SUPER + SHIFT + L", workspaces.toggle_dock, "Toggle dock mode (DP-3 only)")

-- Audio and media -------------------------------------------------------------
local held = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", script("volume up"), "Volume up", held)
bind("XF86AudioLowerVolume", script("volume down"), "Volume down", held)
bind("XF86AudioMute", script("volume mute"), "Mute", { locked = true })
bind("XF86AudioMicMute", script("volume mic"), "Mute microphone", { locked = true })
bind("XF86AudioPlay", script("media toggle"), "Play / pause", { locked = true })
bind("XF86AudioPause", script("media toggle"), "Play / pause", { locked = true })
bind("XF86AudioNext", script("media next"), "Next track", { locked = true })
bind("XF86AudioPrev", script("media previous"), "Previous track", { locked = true })
bind("XF86AudioStop", script("media stop"), "Stop playback", { locked = true })

-- Dictation -------------------------------------------------------------------
-- Push-to-talk: voxtype records while the key is held and types the transcript
-- into the focused window on release. Its config and docs: ~/repos/dictation.
local dictating = false
bind("SUPER + V", function()
    dictating = true
    hl.exec_cmd("voxtype record start")
end, "Dictate: hold to talk")
-- Letting go of Super before V must still end the recording, and by default it
-- does not: the release no longer matches "SUPER + V", and once a modifier comes
-- up Hyprland shadows (skips) every bind on a key that is still held. So the
-- release is bound to V under any modifiers and marked transparent, which
-- exempts it from shadowing. It passes the key through and does nothing unless
-- a dictation is running, which keeps ordinary typing untouched.
bind("V", function()
    if not dictating then return end
    dictating = false
    hl.exec_cmd("voxtype record stop")
end, "Dictate: release to type", { release = true, ignore_mods = true, non_consuming = true, transparent = true })
bind("SUPER + SHIFT + V", run("kitty --class dictation-fix -o font_size=14 -e dictation fix"), "Dictate: correct the last dictation")
bind("SUPER + CTRL + V", function()
    dictating = false
    hl.exec_cmd("voxtype record cancel")
end, "Dictate: discard the recording")

-- Screenshots -----------------------------------------------------------------
bind("SUPER + Print", script("screenshot full"), "Screenshot: everything")
bind("SUPER + SHIFT + Print", script("screenshot area"), "Screenshot: select an area")
bind("ALT + Print", script("screenshot window"), "Screenshot: active window")
bind("SUPER + SHIFT + S", script("screenshot annotate"), "Screenshot: select an area, annotate in swappy")
bind("SUPER + CTRL + Print", script("screenshot full 5"), "Screenshot: everything, in 5 seconds")
bind("SUPER + CTRL + SHIFT + Print", script("screenshot full 10"), "Screenshot: everything, in 10 seconds")
