#!/usr/bin/env bash
monitor=$(hyprctl -j activeworkspace | jq -r '.monitor')
case "$monitor" in
  DP-2)     marker="per-monitor/dp2.jsonc"  ;;
  HDMI-A-1) marker="per-monitor/hdmi.jsonc" ;;
  *)        exit 0 ;;
esac
pkill -SIGUSR1 -f "waybar -c .*${marker}"
