-- The AIO pump-head LCD in lianli-linux desktop mode: a 480x480 headless output
-- that lianli-session streams to the screen. case-console (~/repos/case-console)
-- serves the screensaver page and one chromium app window fills the output.
local OUTPUT = "LianLi-a660a233619714875c45c390" -- stable per device, derived from its USB identity
local WORKSPACE = "41"

-- Far from every real monitor and touching none of them, so the cursor can't
-- wander onto the pump head.
hl.monitor({ output = OUTPUT, mode = "480x480@60", position = "-5000x-5000", scale = 1.0 })
hl.workspace_rule({ workspace = WORKSPACE, monitor = OUTPUT, default = true, persistent = true })

-- Not fullscreen: rules.lua makes fullscreen windows inhibit idle, and this one never closes.
hl.window_rule({
    name = "case-screen",
    match = { class = "^(chrome-127\\.0\\.0\\.1__saver-Default)$" },
    workspace = WORKSPACE .. " silent",
    float = true,
    size = { 480, 480 },
    move = { 0, 0 },
    border_size = 0,
    rounding = 0,
    no_shadow = true,
    no_initial_focus = true,
})

-- Lockdown: the pump head shows the case screen and nothing else, and it never
-- keeps focus. Anything else that lands there (a new window opened while it had
-- focus, a workspace jump onto 41) is sent back to the main monitor, the last
-- real monitor that had focus. Windows of class case-* are allowed, for things
-- launched on purpose, e.g. `kitty --class case-btop -e btop`.
local M = {}
local main = nil
local SAVER = "chrome-127.0.0.1__saver-Default"

local function allowed(window)
    return window.class == SAVER or window.class:match("^case%-") ~= nil
end

local function main_monitor()
    local monitor = main and hl.get_monitor(main)
    if monitor then return monitor end
    for _, candidate in ipairs(hl.get_monitors()) do
        if candidate.name ~= OUTPUT then return candidate end
    end
end

local function focus_main()
    local monitor = main_monitor()
    if not monitor then return end
    hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    hl.dispatch(hl.dsp.cursor.move({ x = monitor.x + monitor.width // 2, y = monitor.y + monitor.height // 2 }))
end

local function evict_strays()
    local monitor = main_monitor()
    local workspace = monitor and monitor.active_workspace
    if not workspace then return end
    for _, window in ipairs(hl.get_windows({ monitor = OUTPUT })) do
        if not allowed(window) then
            hl.dispatch(hl.dsp.window.move({ window = window, workspace = workspace.id, follow = false }))
        end
    end
end

hl.on("monitor.focused", function(monitor)
    if monitor.name ~= OUTPUT then
        main = monitor.name
    else
        -- A focus change dispatched inside this event is dropped, so bounce on the next tick.
        hl.timer(focus_main, { timeout = 1, type = "oneshot" })
    end
end)
for _, event in ipairs({ "window.open", "window.move_to_workspace" }) do
    hl.on(event, evict_strays)
end

-- The saver floats at a global position, and a monitor dropping out and coming
-- back (the main display powered off and on) re-lays out the outputs and leaves
-- it near 0,0, drawn over the main monitor's corner. Pin it back to the pump
-- head's origin once the new layout has settled.
local function pin_saver()
    local output = hl.get_monitor(OUTPUT)
    if not output then return end
    for _, window in ipairs(hl.get_windows()) do
        if window.class == SAVER and (window.at.x ~= output.x or window.at.y ~= output.y) then
            hl.dispatch(hl.dsp.window.move({ window = window, x = output.x, y = output.y }))
        end
    end
end

for _, event in ipairs({ "monitor.added", "monitor.removed", "monitor.layout_changed" }) do
    hl.on(event, function() hl.timer(pin_saver, { timeout = 500, type = "oneshot" }) end)
end

-- The emergency exit (Super+Escape): clear the pump head, re-pin the saver,
-- then focus the main monitor and put the cursor in its centre.
function M.rescue()
    evict_strays()
    pin_saver()
    focus_main()
end

-- case-console.service (the page server) is enabled in systemd; the window
-- needs the Wayland session, so it starts with Hyprland.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start case-console-screen.service")
end)

return M
