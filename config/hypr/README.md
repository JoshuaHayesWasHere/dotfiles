# Hyprland, in Lua

A hand-written Lua config. It keeps only the features in use, runs the
multi-monitor workspace logic inside Hyprland instead of in shell scripts, and
uses a fixed Catppuccin Mocha palette.

## Layout

| File | Holds |
|------|-------|
| `hyprland.lua` | Entry point: resolves its own directory, loads the modules below |
| `monitors.lua` | Monitor layout. Written by nwg-displays, do not hand-edit |
| `theme.lua` | The Mocha palette, the only place Hyprland colours are defined |
| `settings.lua` | Environment, look and feel, layouts, input |
| `workspaces.lua` | Per-monitor workspace blocks, monitor swap, dock mode |
| `rules.lua` | Window rules for installed apps |
| `binds.lua` | Every keybind, each with a description |
| `autostart.lua` | Processes started with the session |
| `hyprlock.conf`, `hypridle.conf` | Lock screen and its logind wiring |
| `scripts/` | POSIX `sh` helpers, listed below |

## Scripts

| Script | Does | Called from |
|--------|------|-------------|
| `volume up\|down\|mute\|mic` | Default sink and source through `wpctl`, one self-replacing notification | media keys, waybar, swaync |
| `media toggle\|next\|previous\|stop` | Drives the active MPRIS player | media keys |
| `screenshot full\|area\|window\|annotate [delay]` | Saves to `~/Pictures/Screenshots` and copies; `annotate` opens swappy | `Print` binds |
| `clipboard` | cliphist history in rofi | `Super+Alt+V` |
| `keybinds [markdown]` | Cheat sheet built from the live binds; `markdown` prints the table kept in `docs/keybinds.md` | `Super+Shift+K` |
| `wallpaper pick\|random\|restore` | One image on every monitor through awww | `Super+End`, `Ctrl+Alt+W`, autostart |
| `powermenu` | Toggles wlogout, sized to the focused monitor | `Ctrl+Alt+P`, swaync |

Check them with `shellcheck -s sh scripts/*`.

## What depends on this config

The bar, notification panel, power menu and overview live in their own
directories and call into this one:

- `waybar/config.jsonc` is the one bar definition; `waybar/per-monitor/*.jsonc`
  include it and name an output. `autostart.lua` starts one waybar per monitor.
- `swaync/config.json` and `wlogout/layout` call `scripts/powermenu`,
  `scripts/volume`, `loginctl lock-session` and the Lua exit dispatch.
- `quickshell` (the `Super+A` overview) dispatches workspace and window moves.

**Dispatching from outside.** With a Lua config, `hyprctl dispatch` takes a Lua
expression. The legacy form (`hyprctl dispatch workspace 3`) is a syntax error:

```bash
hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'
hyprctl dispatch 'hl.dsp.exit()'
```

Clicking a workspace in waybar needs a waybar that speaks this form: the fix
(Alexays/Waybar#5013) is merged upstream but newer than the 0.15.0 release, so
until the next release it needs `waybar-git`. Scrolling over the workspaces
works on any version, since those commands are spelled out in the config.

## Behaviour worth knowing

- `Super+J` / `Super+K` are focus down / up.
- `Super+Shift+M` swaps windows with the next monitor to the right.
- The wallpaper is the same image on every monitor. The current choice is a
  symlink at `~/.local/state/hypr/wallpaper`, which the lock screen also uses.
- `Super+Shift+S` opens the selected area directly in swappy.
- `Super+V` is push-to-talk dictation: hold, speak, release, and the text is
  typed into the focused window. `autostart.lua` starts the `voxtype` daemon
  and loads its punctuation model. Everything else about it (config, models,
  tuning) lives in `~/repos/dictation`. The release half of the bind is on a
  bare `V` and marked `transparent` on purpose; the comment in `binds.lua`
  says why. `Super+Shift+V` opens the last dictation in a floating editor to
  correct it (`dictation fix`, Escape closes it); `Super+Ctrl+V` discards a
  recording in progress.
- Hardware cursors and direct scanout are on their defaults. If the cursor
  glitches, set `cursor = { no_hardware_cursors = 1 }` in `settings.lua`.
- Colours are fixed. Nothing recolours from the wallpaper.

## Checking it

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
hyprctl configerrors        # in a running session
```

To try a change without leaving the current session, run it nested. It opens
as a window with its own wallpaper, bar and overview. `autostart.lua` detects
the nested run and skips everything that belongs to the user rather than to
the compositor (the systemd environment import, hypridle, swaync, the tray
applets, the dictation daemon, the clipboard watchers), so the real session is left alone.

```bash
Hyprland -c ~/.config/hypr/hyprland.lua
```

The red `libseat` / `DRM Backend failed` / `NO PREFERRED MODE` lines it prints
are normal for a nested run: the real session owns the seat and the nested
output has no fixed modes.

## If a session does not come up

`Ctrl+Alt+F3`, log in on the console, and ask Hyprland what it objects to:

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
```

Fix that, or go back to the last commit that worked with
`git -C ~/dotfiles log --oneline -- config/hypr` and `git checkout <commit> -- config/hypr`,
then return to the login screen with `Ctrl+Alt+F1`.
