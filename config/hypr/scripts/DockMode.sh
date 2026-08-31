#!/usr/bin/env bash
# Toggle "dock mode": disable DP-1 (middle) and DP-2 (left, portrait) so a
# docked laptop can claim them, reflowing their windows onto DP-3 (the
# smaller right monitor, which stays on). Running again restores the normal
# 3-monitor layout from monitors.conf.
#
# State is tracked by a marker file rather than by re-probing monitor state,
# so the reverse direction is exact even if DP-3's own workspace has since
# changed. Workspace contents move via movetoworkspacesilent, same approach
# as SwapMonitorContents.sh; workspace IDs and their monitor bindings
# (workspaces.conf) are untouched.
#
# Hyprland's own monitor-disable path does move a disabled monitor's
# workspaces (and their windows) onto a remaining monitor on its own, but
# there are known-issue reports of workspaces sticking to a disabled output
# in some versions (e.g. hyprwm/Hyprland#12059), so we don't rely on it: we
# reflow every window on every workspace owned by DP-1/DP-2 (per
# `hyprctl -j workspaces`, not just each monitor's active workspace) onto
# DP-3 ourselves, before disabling.

set -euo pipefail

state_file="$HOME/.cache/hypr_dock_mode_active"
mon_off="DP-1"
mon_off2="DP-2"
mon_on="DP-3"

if [[ -f "$state_file" ]]; then
    # --- Undock: re-enable DP-1 and DP-2 with their monitors.conf geometry.
    hyprctl keyword monitor "DP-1,2560x1440@59.95,3165x363,1.0" >/dev/null
    hyprctl keyword monitor "DP-2,1920x1080@60.0,2085x363,1.0" >/dev/null
    hyprctl keyword monitor "DP-2,transform,1" >/dev/null
    rm -f "$state_file"
else
    # --- Dock: reflow every window on every workspace owned by DP-1/DP-2
    # (not just each monitor's active workspace) onto DP-3's active
    # workspace, then disable both outputs.
    ws_on=$(hyprctl -j monitors | jq -r --arg m "$mon_on" '.[] | select(.name == $m) | .activeWorkspace.id')

    ws_ids=$(hyprctl -j workspaces | jq -r --arg a "$mon_off" --arg b "$mon_off2" \
        '[.[] | select(.monitor == $a or .monitor == $b) | .id] | .[]')
    for ws in $ws_ids; do
        clients=$(hyprctl -j clients | jq -r --argjson w "$ws" '[.[] | select(.workspace.id == $w) | .address] | .[]')
        for addr in $clients; do
            hyprctl dispatch movetoworkspacesilent "$ws_on,address:$addr"
        done
    done

    hyprctl keyword monitor "DP-1,disable" >/dev/null
    hyprctl keyword monitor "DP-2,disable" >/dev/null

    touch "$state_file"
fi
