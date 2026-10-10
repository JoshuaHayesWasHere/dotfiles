-- Per-monitor workspace blocks. Each monitor owns ten workspaces; Super+N means
-- "workspace N of whichever monitor has focus". All of it runs inside
-- Hyprland, so a workspace switch spawns no process.
local M = {}

local BLOCK = 10      -- workspaces per monitor
local ALWAYS = 5      -- 1..ALWAYS are always shown, the rest appear on demand

-- Monitor name -> first workspace id minus one.
M.offsets = {
    ["DP-2"] = 0,     -- left, portrait: 1-10
    ["DP-3"] = 10,    -- right: 11-20
    ["DP-1"] = 20,    -- centre: 21-30
}

-- One rule per workspace binds it to its monitor. Workspaces above ALWAYS start
-- out non-persistent; declaring the same rule again with `persistent` flipped is
-- how an on-demand workspace is kept visible in the bar while it, or a higher
-- one, is in use. `shown` remembers the last value declared for each.
local shown = {}

local function declare(monitor, offset, index, persistent)
    hl.workspace_rule({
        workspace = tostring(offset + index),
        monitor = monitor,
        default = (index == 1),
        persistent = persistent,
    })
end

for monitor, offset in pairs(M.offsets) do
    shown[monitor] = {}
    for i = 1, BLOCK do
        declare(monitor, offset, i, i <= ALWAYS)
        if i > ALWAYS then shown[monitor][i] = false end
    end
end

-- Highest local index that should be shown on a monitor: the highest one
-- holding windows, or the one being looked at, but never below ALWAYS.
local function watermark(monitor, offset)
    local water = ALWAYS
    for i = ALWAYS + 1, BLOCK do
        local ws = hl.get_workspace(offset + i)
        if ws and ws.windows > 0 then water = i end
    end
    local active = hl.get_active_workspace(monitor)
    if active then
        local index = active.id - offset
        if index > water and index <= BLOCK then water = index end
    end
    return water
end

local function refresh()
    for monitor, offset in pairs(M.offsets) do
        if hl.get_monitor(monitor) then
            local water = watermark(monitor, offset)
            for i, was in pairs(shown[monitor]) do
                local now = i <= water
                if now ~= was then
                    declare(monitor, offset, i, now)
                    shown[monitor][i] = now
                end
            end
        end
    end
end

for _, event in ipairs({ "workspace.active", "window.open", "window.close", "window.move_to_workspace" }) do
    hl.on(event, refresh)
end

-- Workspace id for local index `index` on the focused monitor.
local function target(index)
    local monitor = hl.get_active_monitor()
    local offset = monitor and M.offsets[monitor.name]
    return offset and offset + index
end

function M.focus(index)
    local id = target(index)
    if id then hl.dispatch(hl.dsp.focus({ workspace = id })) end
end

function M.move(index, follow)
    local id = target(index)
    if id then hl.dispatch(hl.dsp.window.move({ workspace = id, follow = follow })) end
end

local function move_all(windows, workspace)
    for _, window in ipairs(windows) do
        hl.dispatch(hl.dsp.window.move({ window = window, workspace = workspace, follow = false }))
    end
end

-- Swap the visible windows of the focused monitor with the next monitor to its
-- right (wrapping round). Workspaces stay on their own monitors; only the
-- windows change places.
function M.swap_with_next_monitor()
    local monitors = hl.get_monitors()
    table.sort(monitors, function(a, b) return a.x < b.x end)
    local here = hl.get_active_monitor()
    if not here or #monitors < 2 then return end
    local there
    for i, monitor in ipairs(monitors) do
        if monitor.name == here.name then there = monitors[i % #monitors + 1] end
    end
    local a, b = here.active_workspace, there and there.active_workspace
    if not a or not b then return end
    local from_a, from_b = hl.get_workspace_windows(a.id), hl.get_workspace_windows(b.id)
    move_all(from_a, b.id)
    move_all(from_b, a.id)
end

-- Dock mode: hand DP-1 and DP-2 to the docked laptop and keep working on DP-3.
-- Windows on the outgoing monitors are gathered onto DP-3 first. Toggling again
-- re-enables them and re-applies monitors.lua. A config reload also restores
-- every monitor.
local DOCK_KEEP = "DP-3"
local docked = false

function M.toggle_dock()
    if docked then
        -- Monitor rules merge by output, and monitors.lua never mentions
        -- `disabled`, so it has to be cleared before the layout is re-applied.
        for name in pairs(M.offsets) do
            if name ~= DOCK_KEEP then hl.monitor({ output = name, disabled = false }) end
        end
        dofile(CONFIG_DIR .. "/monitors.lua")
        docked = false
        return
    end
    local keep = hl.get_monitor(DOCK_KEEP)
    if not keep or not keep.active_workspace then return end
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.name ~= DOCK_KEEP then
            move_all(hl.get_windows({ monitor = monitor.name }), keep.active_workspace.id)
        end
    end
    for name in pairs(M.offsets) do
        if name ~= DOCK_KEEP then hl.monitor({ output = name, disabled = true }) end
    end
    docked = true
end

return M
