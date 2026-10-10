# Screenshots

The images here are taken on an off-screen copy of the desktop, not on the real
one, so nothing private is ever in frame and the real session is not disturbed.
The same setup is the way to try a theme change before living with it.

## How the off-screen desktop is started

Hyprland needs a parent compositor to start under, and `labwc` can run with no
screen at all. A second Hyprland is started inside it with a throwaway `$HOME`
whose `~/.config` entries are links into a checkout of this repo, and is then
given a virtual monitor of its own:

```sh
# 1. a parent with no physical output
WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 labwc &

# 2. Hyprland inside it, reading the checkout under test
HOME=/tmp/rig/home XDG_CONFIG_HOME=/tmp/rig/home/.config \
  WAYLAND_DISPLAY=wayland-0 Hyprland -c /tmp/rig/home/.config/hypr/hyprland.lua &

# 3. from then on, address that instance (see `hyprctl instances`)
export HYPRLAND_INSTANCE_SIGNATURE=<its signature> WAYLAND_DISPLAY=<its socket>
hyprctl output create headless SHOT-1
hyprctl dispatch 'hl.monitor({ output = "SHOT-1", mode = "2560x1440@60", position = "0x0", scale = 1.0 })'

# 4. start programs with that environment, then capture
grim -o SHOT-1 desktop.png
```

`autostart.lua` already recognises a nested or headless run and skips everything
that belongs to the user (notifications, the tray, the clipboard watchers), so
the real session keeps its own. The bar is started by hand with a config whose
`output` is the virtual monitor.

Two things to know:

- `swaync` owns a name on the session bus, and the real one already has it. To
  see the notification style, run a second one on a private bus:
  `dbus-run-session -- sh -c 'swaync & sleep 1; notify-send Title Body; sleep 5'`.
- Stop programs in the off-screen desktop by process id. `pkill rofi` would also
  close a launcher open on the real screen.
