local theme = require("theme")

-- Environment -----------------------------------------------------------------
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("EDITOR", "nvim")
hl.env("CARGO_HOME", os.getenv("HOME") .. "/.local/share/cargo")
hl.env("RUSTUP_HOME", os.getenv("HOME") .. "/.local/share/rustup")

-- Look and feel ---------------------------------------------------------------
hl.config({
    general = {
        border_size = 2,
        gaps_in = 2,
        gaps_out = 4,
        col = {
            active_border = theme.rgb("blue"),
            inactive_border = theme.rgb("surface1"),
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        dim_inactive = true,
        dim_strength = 0.1,
        shadow = {
            enabled = true,
            range = 3,
            render_power = 1,
            color = theme.rgb("blue"),
            color_inactive = theme.rgb("surface1"),
        },
        blur = { enabled = false },
    },
    animations = { enabled = true },
})

hl.curve("quart", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "quart", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "quart" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "quart" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "quart" })

-- Layouts ---------------------------------------------------------------------
hl.config({
    dwindle = { preserve_split = true },
    master = { new_status = "master", new_on_top = true, mfact = 0.5 },
})

-- Input -----------------------------------------------------------------------
hl.config({
    input = {
        kb_layout = "us",
        repeat_rate = 50,
        repeat_delay = 300,
        numlock_by_default = true,
        follow_mouse = 1,
        float_switch_override_focus = 0,
    },
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
    },
    cursor = {
        sync_gsettings_theme = true,
        enable_hyprcursor = false,
        warp_on_change_workspace = 2,
        no_warps = true,
    },
})

-- Everything else -------------------------------------------------------------
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 2,
        mouse_move_enables_dpms = true,
        focus_on_activate = false,
        initial_workspace_tracking = 0,
        middle_click_paste = false,
        enable_anr_dialog = true,
        anr_missed_pings = 15,
    },
    xwayland = { force_zero_scaling = true },
})
