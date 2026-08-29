#!/usr/bin/env bash
# Resolve a local workspace index (1..10) to the global ID for the focused
# monitor, dispatch the requested action, and adjust the visible-dot
# watermark on each monitor.
#
# Each monitor owns a contiguous block of 10 workspaces (see OFFSETS below and
# workspaces.conf). Local index N on a monitor maps to global (offset + N), so
# SUPER+2 always means "the 2nd workspace of whatever monitor is focused".
#
# Per-monitor watermark = max(5, highest local index with windows, active local idx).
# Slots 6..10 above the watermark must be depersisted so empty ones disappear.
# Hyprland's `keyword persistent:false` cannot un-persist an already-persistent
# workspace at runtime, so we use `hyprctl reload` (which clears all runtime
# keyword overrides and re-reads workspaces.conf) and re-apply only what each
# monitor actually needs.
#
# Usage: WorkspaceOnMonitor.sh <focus|move|movesilent> <1..10>

set -euo pipefail
action="$1"
idx="$2"

# Monitor -> base offset. Each monitor owns [offset+1 .. offset+10].
declare -A OFFSETS=(
  [DP-2]=0    # workspaces 1-10
  [DP-3]=10   # workspaces 11-20
  [DP-1]=20   # workspaces 21-30
)

monitor=$(hyprctl -j activeworkspace | jq -r '.monitor')

if [[ -z "${OFFSETS[$monitor]+x}" ]]; then
    echo "no workspace block defined for monitor: $monitor" >&2
    exit 1
fi
offset=${OFFSETS[$monitor]}

ws=$((offset + idx))

# Phase 1: make sure target slot exists (and any slots between 5 and target).
for ((i = 6; i <= idx; i++)); do
    g=$((offset + i))
    hyprctl keyword workspace "$g,monitor:$monitor,persistent:true" >/dev/null
done

# Phase 2: dispatch the requested action.
case "$action" in
  focus)       hyprctl dispatch workspace "$ws" ;;
  move)        hyprctl dispatch movetoworkspace "$ws" ;;
  movesilent)  hyprctl dispatch movetoworkspacesilent "$ws" ;;
  *) echo "unknown action: $action" >&2; exit 2 ;;
esac

# --- Watermark management --------------------------------------------------
# Compute desired watermark for a given monitor name and offset.
desired_watermark() {
    local mon="$1" mon_offset="$2"
    local active_id active_local max_used=0 g n
    active_id=$(hyprctl -j monitors | jq -r --arg m "$mon" '.[] | select(.name == $m) | .activeWorkspace.id')
    active_local=$((active_id - mon_offset))
    for ((i = 1; i <= 10; i++)); do
        g=$((mon_offset + i))
        n=$(hyprctl -j workspaces | jq --argjson w "$g" '[.[] | select(.id == $w) | .windows] | first // 0')
        (( n > 0 )) && max_used=$i
    done
    local water=5
    (( max_used > water )) && water=$max_used
    (( active_local > 0 && active_local <= 10 && active_local > water )) && water=$active_local
    echo "$water"
}

# Detect whether any slot above this monitor's watermark is currently
# persistent (left over from a previous higher visit). If so, shrink.
this_water=$(desired_watermark "$monitor" "$offset")
need_shrink=0
for ((i = this_water + 1; i <= 10; i++)); do
    g=$((offset + i))
    p=$(hyprctl -j workspaces | jq -r --argjson w "$g" '[.[] | select(.id == $w) | .ispersistent] | first // false')
    if [[ "$p" == "true" ]]; then
        need_shrink=1
        break
    fi
done

if (( need_shrink )); then
    # Snapshot every monitor's desired watermark BEFORE reload so we can
    # re-apply on-demand slots (6..water) for all of them, not just this one.
    declare -A WATER=()
    for mon in "${!OFFSETS[@]}"; do
        WATER[$mon]=$(desired_watermark "$mon" "${OFFSETS[$mon]}")
    done

    hyprctl reload >/dev/null

    for mon in "${!OFFSETS[@]}"; do
        mon_offset=${OFFSETS[$mon]}
        for ((i = 6; i <= ${WATER[$mon]}; i++)); do
            g=$((mon_offset + i))
            hyprctl keyword workspace "$g,monitor:$mon,persistent:true" >/dev/null
        done
    done
fi
