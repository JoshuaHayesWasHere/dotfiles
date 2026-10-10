# RGB lighting (OpenRGB)

The daemon runs as `openrgb --server --config /etc/openrgb --profile default`, so
the profile that matters lives in **`/etc/openrgb/`**, not `~/.config/OpenRGB`
(that one is only the GUI's scratch directory and is deliberately untracked).

Four pieces make up the setup, all tracked in `openrgb/` here:

| Repo file | Installed to | Purpose |
|-----------|--------------|---------|
| `default.orp` | `/etc/openrgb/default.orp` | zone geometry (D_LED = 36 LEDs) and modes |
| `openrgb-restore-lighting` | `/usr/local/bin/` | re-applies colors after detection settles |
| `openrgb.service.d/profile.conf` | `/etc/systemd/system/openrgb.service.d/` | loads the profile and runs the SDK server |
| `openrgb.service.d/apply-lighting.conf` | same | runs the restore hook as `ExecStartPost` |

Full reinstall:

```bash
yay -S openrgb
sudo ln -sfn ~/dotfiles/openrgb/default.orp /etc/openrgb/default.orp
sudo ln -sfn ~/dotfiles/openrgb/openrgb-restore-lighting /usr/local/bin/openrgb-restore-lighting
sudo mkdir -p /etc/systemd/system/openrgb.service.d
sudo ln -sfn ~/dotfiles/openrgb/openrgb.service.d/profile.conf \
             /etc/systemd/system/openrgb.service.d/profile.conf
sudo ln -sfn ~/dotfiles/openrgb/openrgb.service.d/apply-lighting.conf \
             /etc/systemd/system/openrgb.service.d/apply-lighting.conf
sudo systemctl daemon-reload
sudo systemctl enable --now openrgb.service
```

Home Assistant drives the lights through the SDK server.

**Detection runs once, at daemon start.** OpenRGB caches a file descriptor per HID
device and never re-probes. If a USB HID device renumbers while the daemon is up
(a wireless receiver reconnecting is the usual cause), OpenRGB keeps writing into
the dead handle, which wedges its whole HID path and silently kills every other
HID device with it. SMBus devices such as the RAM keep working, so the symptom is
partial: RAM controllable, motherboard and fans dead. The fix is
`sudo systemctl restart openrgb.service`. To stop it recurring, disable the
detector for any device you do not actually control from Home Assistant:

```bash
sudo python3 -c "
import json
p='/etc/openrgb/OpenRGB.json'
d=json.load(open(p)); d['Detectors']['detectors']['VSG Mintaka']=False
json.dump(d,open(p,'w'),indent=4)"
```

**Watch for drift.** Unlike keyd, OpenRGB rewrites its own config files when you
save a profile, and it replaces rather than edits in place, which can clobber
the symlink and leave `/etc/openrgb/default.orp` as a regular file while the repo
copy silently goes stale. After saving a profile in the GUI, check it:

```bash
ls -l /etc/openrgb/default.orp     # want: -> ~/dotfiles/openrgb/default.orp
```

If it came back as a regular file, fold the change in and relink:

```bash
sudo cp /etc/openrgb/default.orp ~/dotfiles/openrgb/default.orp
sudo chown $USER:$USER ~/dotfiles/openrgb/default.orp
sudo ln -sfn ~/dotfiles/openrgb/default.orp /etc/openrgb/default.orp
```
