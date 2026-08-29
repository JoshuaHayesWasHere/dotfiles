#!/bin/bash
# Apply the current wallpaper to ALL connected monitors at startup.
# awww (like swww) only restores outputs it knew about last session, so a
# monitor that connects late (e.g. DP-3) can come up blank. Re-applying with
# no `-o` targets every current output and makes the wallpaper stick.

wallpaper="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
[ -f "$wallpaper" ] || exit 0

# Ensure the daemon is up.
awww query >/dev/null 2>&1 || awww-daemon --format xrgb &

# Wait for the daemon to accept connections (max ~5s).
for _ in $(seq 1 25); do
	awww query >/dev/null 2>&1 && break
	sleep 0.2
done

awww img "$wallpaper" --transition-type none
