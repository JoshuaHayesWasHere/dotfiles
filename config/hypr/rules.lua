-- Window and layer rules, limited to applications that are actually installed.
local DIALOG = { "monitor_w*0.7", "monitor_h*0.7" }

-- Small utility windows float, centred, at a comfortable size.
hl.window_rule({
    name = "settings-apps",
    match = { class = "^(nwg-displays|nwg-look|qt5ct|qt6ct|pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager|xarchiver|xdg-desktop-portal-gtk)$" },
    float = true,
    center = true,
    size = DIALOG,
})
hl.window_rule({ name = "kvantum", match = { title = "Kvantum Manager" }, float = true, center = true, size = DIALOG })

hl.window_rule({
    name = "viewers",
    match = { class = "^(org.gnome.Loupe|gnome-system-monitor|org.gnome.SystemMonitor|mpv)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "calculator",
    match = { class = "^([Qq]alculate-gtk)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.25", "monitor_h*0.3" },
})

-- The editor that Super+Shift+V opens on the last dictation.
hl.window_rule({
    name = "dictation-fix",
    match = { class = "^(dictation-fix)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.5", "monitor_h*0.3" },
})

-- File choosers and similar dialogs.
hl.window_rule({
    name = "file-dialogs",
    match = { title = "^(Open Files?|Save As|Save File|Add Folder to Workspace)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.7", "monitor_h*0.6" },
})
hl.window_rule({
    name = "thunar-progress",
    match = { class = "^(thunar)$", title = "^(File Operation Progress)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.26", "monitor_h*0.18" },
})
hl.window_rule({ name = "polkit-prompt", match = { title = "^(Authentication Required)$" }, float = true, center = true })

hl.window_rule({
    name = "picture-in-picture",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = { "monitor_w*0.3", "monitor_h*0.3" },
    move = { "monitor_w*0.68", "monitor_h*0.07" },
})

-- Steam's secondary windows (friends list, settings) float; the main one tiles.
hl.window_rule({ name = "steam-popups", match = { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, float = true })

-- Anything fullscreen keeps the session from idling.
hl.window_rule({ name = "fullscreen-inhibits-idle", match = { fullscreen = true }, idle_inhibit = "fullscreen" })

-- Apps asking to maximise themselves are ignored; tiling decides the size.
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
