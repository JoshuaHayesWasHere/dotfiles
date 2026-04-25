#!/usr/bin/env bash
# Swap the windows between DP-2's active workspace and HDMI-A-1's active workspace.
# Workspace IDs stay on their bound monitors; only window contents move.

set -euo pipefail

mon_a="DP-2"
mon_b="HDMI-A-1"
scratch=999   # holding workspace; not bound to any monitor

ws_a=$(hyprctl -j monitors | jq -r --arg m "$mon_a" '.[] | select(.name == $m) | .activeWorkspace.id')
ws_b=$(hyprctl -j monitors | jq -r --arg m "$mon_b" '.[] | select(.name == $m) | .activeWorkspace.id')

clients_a=$(hyprctl -j clients | jq -r --argjson w "$ws_a" '[.[] | select(.workspace.id == $w) | .address]')
clients_b=$(hyprctl -j clients | jq -r --argjson w "$ws_b" '[.[] | select(.workspace.id == $w) | .address]')

# Stash B's windows in scratch, send A's to B, then send scratch to A.
for addr in $(echo "$clients_b" | jq -r '.[]'); do
    hyprctl dispatch movetoworkspacesilent "$scratch,address:$addr"
done
for addr in $(echo "$clients_a" | jq -r '.[]'); do
    hyprctl dispatch movetoworkspacesilent "$ws_b,address:$addr"
done
for addr in $(echo "$clients_b" | jq -r '.[]'); do
    hyprctl dispatch movetoworkspacesilent "$ws_a,address:$addr"
done
