#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Searchable, categorized keybinds viewer using rofi.
# Filter switching (Alt+N) uses rofi's script mode so the window stays open
# and the listview refreshes in place — no relaunch flicker.

# ======================================================================
# SCRIPT MODE — rofi sets ROFI_RETV when it calls this script back.
# The script emits the (possibly filtered) listview content + the message
# header chips on each invocation. ROFI_DATA carries the active filter
# index across invocations.
# ======================================================================
if [[ -n "${ROFI_RETV:-}" ]]; then
    cache="${KEYBINDS_CACHE:?missing KEYBINDS_CACHE env var}"
    [[ -f "$cache" ]] || exit 1
    display=$(cat "$cache")

    mapfile -t cat_array < <(printf '%s\n' "$display" | sed -n 's/^\[\([^]]*\)\].*/\1/p' | sort -u)
    filters=("All" "${cat_array[@]}")

    hotkey_label=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "-" "=")
    custom_n=(10 1 2 3 4 5 6 7 8 9 11 12)

    nslots=${#filters[@]}
    (( nslots > ${#hotkey_label[@]} )) && nslots=${#hotkey_label[@]}

    # ROFI_RETV (custom-N exit code = 9+N) → filter index
    declare -A retv_to_idx
    for ((i = 0; i < nslots; i++)); do
        retv_to_idx[$((9 + custom_n[i]))]=$i
    done

    current_idx="${ROFI_DATA:-0}"
    case "$ROFI_RETV" in
        0)   ;;                 # initial call — keep current_idx
        1|2) exit 1 ;;          # user picked an item → abort modi (closes rofi)
        *)
            if [[ -n "${retv_to_idx[$ROFI_RETV]:-}" ]]; then
                current_idx="${retv_to_idx[$ROFI_RETV]}"
            fi
            ;;
    esac

    # Header chips (compact; long names abbreviated for 1080p widths).
    mesg=""
    for ((i = 0; i < nslots; i++)); do
        case "${filters[$i]}" in
            "Apps & Launcher") short="Apps" ;;
            "Media & Audio")   short="Media" ;;
            "Screenshots")     short="Shots" ;;
            "Workspaces")      short="Wksp" ;;
            "Utilities")       short="Util" ;;
            "Theming")         short="Theme" ;;
            *)                 short="${filters[$i]}" ;;
        esac
        if (( i == current_idx )); then
            mesg+="<b>●⎇${hotkey_label[$i]} ${short}</b>  "
        else
            mesg+="⎇${hotkey_label[$i]} ${short}  "
        fi
    done

    # Rofi script protocol headers: \0KEY\x1fVALUE\n
    # use-hot-keys is required for custom keybindings to call the script
    # back instead of exiting rofi.
    printf '\0prompt\x1f%s\n'       "${filters[$current_idx]}"
    printf '\0message\x1f%s\n'      "$mesg"
    printf '\0data\x1f%s\n'         "$current_idx"
    printf '\0no-custom\x1ftrue\n'
    printf '\0use-hot-keys\x1ftrue\n'

    if (( current_idx == 0 )); then
        printf '%s\n' "$display"
    else
        printf '%s\n' "$display" | grep -F "[${filters[$current_idx]}]"
    fi
    exit 0
fi

# ======================================================================
# LAUNCHER MODE — invoked by user (e.g. via Hyprland keybind).
# Parses the bind config files, caches the formatted listview, then
# starts rofi pointing back at this script as a custom modi.
# ======================================================================

# kill yad to not interfere with this binds
pkill yad || true

# check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# define the config files
keybinds_conf="$HOME/.config/hypr/configs/Keybinds.conf"
user_keybinds_conf="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
laptop_conf="$HOME/.config/hypr/UserConfigs/Laptops.conf"
rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"

files=("$keybinds_conf" "$user_keybinds_conf")
[[ -f "$laptop_conf" ]] && files+=("$laptop_conf")

# Parse, categorize, format. Emits TAB-separated: category \t combo \t description
parsed=$(awk '
function categorize(action, args, comment,    s) {
    s = tolower(action " | " args " | " comment)
    if (action ~ /^(workspace|movetoworkspace|movetoworkspacesilent|togglespecialworkspace)$/) return "Workspaces"
    if (action == "layoutmsg") return "Layout"
    if (action ~ /^(killactive|fullscreen|togglefloating|workspaceopt|togglegroup|changegroupactive|cyclenext|bringactivetotop|movewindow|movewindowpixel|swapwindow|movefocus|resizeactive|resizewindow|pseudo|togglesplit|splitratio|focuscurrentorlast|centerwindow)$/) return "Windows"
    if (action == "global") return "Apps & Launcher"
    if (action == "exec") {
        if (s ~ /screenshot|swappy|grim|slurp/) return "Screenshots"
        if (s ~ /volume|mediactrl|playerctl|airplane|togglemic|mic mute/) return "Media & Audio"
        if (s ~ /lockscreen|wlogout|hyprctl dispatch exit|systemctl suspend|systemctl poweroff|systemctl reboot/) return "Session"
        if (s ~ /waybar/) return "Waybar"
        if (s ~ /changelayout/) return "Layout"
        if (s ~ /wallpaper|rofitheme|changeblur|animations|zshchange|gamemode|opaque toggle|application-style/) return "Theming"
        if (s ~ /workspaceopt|splitratio/) return "Windows"
        if (s ~ /swaync|notification|notif/) return "Utilities"
        if (s ~ /clip|emoji|rofisearch|roficalc|rofibeats|keybinds|refresh|killactiveprocess|drop|keyboardlayout|kool_quick_settings|tak0/) return "Utilities"
        if (s ~ /rofi -show|xdg-open|\$term|\$files/) return "Apps & Launcher"
        if (s ~ /cursor:zoom|zoom_factor/) return "Display"
        return "Other"
    }
    return "Other"
}

function pretty_key(k,    lk) {
    if (k == "code:10") return "1"
    if (k == "code:11") return "2"
    if (k == "code:12") return "3"
    if (k == "code:13") return "4"
    if (k == "code:14") return "5"
    if (k == "code:15") return "6"
    if (k == "code:16") return "7"
    if (k == "code:17") return "8"
    if (k == "code:18") return "9"
    if (k == "code:19") return "0"
    if (k == "Return") return "Enter"
    if (k == "bracketleft") return "["
    if (k == "bracketright") return "]"
    if (k == "mouse:272") return "LeftClick"
    if (k == "mouse:273") return "RightClick"
    if (k == "mouse_down") return "ScrollDown"
    if (k == "mouse_up") return "ScrollUp"
    lk = tolower(k)
    if (lk == "xf86audioraisevolume") return "VolumeUp"
    if (lk == "xf86audiolowervolume") return "VolumeDown"
    if (lk == "xf86audiomute")        return "Mute"
    if (lk == "xf86audiomicmute")     return "MicMute"
    if (lk == "xf86audioplaypause")   return "PlayPause"
    if (lk == "xf86audioplay")        return "Play"
    if (lk == "xf86audiopause")       return "Pause"
    if (lk == "xf86audionext")        return "Next"
    if (lk == "xf86audioprev")        return "Previous"
    if (lk == "xf86audiostop")        return "Stop"
    if (lk == "xf86sleep")            return "Sleep"
    if (lk == "xf86rfkill")           return "RFKill"
    # uppercase single-letter keys for consistency
    if (length(k) == 1 && k ~ /[a-z]/) return toupper(k)
    # title-case common named keys
    if (lk == "tab")   return "Tab"
    if (lk == "up")    return "Up"
    if (lk == "down")  return "Down"
    if (lk == "left")  return "Left"
    if (lk == "right") return "Right"
    if (lk == "end")   return "End"
    if (lk == "home")  return "Home"
    if (lk == "space")  return "Space"
    if (lk == "print")  return "Print"
    if (lk == "comma")  return ","
    if (lk == "period") return "."
    return k
}

function derive(action, args) {
    if (action == "workspace") {
        if (args == "m+1") return "Switch to next monitor workspace"
        if (args == "m-1") return "Switch to previous monitor workspace"
        if (args == "e+1") return "Switch to next workspace"
        if (args == "e-1") return "Switch to previous workspace"
        return "Switch to workspace " args
    }
    if (action == "movetoworkspace") {
        if (args == "special") return "Move window to special workspace"
        if (args == "+1") return "Move window to next workspace"
        if (args == "-1") return "Move window to previous workspace"
        return "Move window to workspace " args " (and follow)"
    }
    if (action == "movetoworkspacesilent") {
        if (args == "+1") return "Move window to next workspace (silent)"
        if (args == "-1") return "Move window to previous workspace (silent)"
        return "Move window to workspace " args " (silent)"
    }
    if (action == "togglespecialworkspace") return "Toggle special workspace"
    if (action == "killactive") return "Close active window"
    if (action == "fullscreen") return (args == "1") ? "Fake fullscreen" : "Fullscreen"
    if (action == "togglefloating") return "Toggle floating mode"
    if (action == "movefocus") {
        if (args == "l") return "Focus left"
        if (args == "r") return "Focus right"
        if (args == "u") return "Focus up"
        if (args == "d") return "Focus down"
    }
    if (action == "movewindow") {
        if (args == "l") return "Move window left"
        if (args == "r") return "Move window right"
        if (args == "u") return "Move window up"
        if (args == "d") return "Move window down"
        if (args == "") return "Move window (mouse drag)"
    }
    if (action == "resizewindow") return "Resize window (mouse drag)"
    if (action == "swapwindow") {
        if (args == "l") return "Swap window left"
        if (args == "r") return "Swap window right"
        if (args == "u") return "Swap window up"
        if (args == "d") return "Swap window down"
    }
    if (action == "resizeactive") return "Resize active window (" args ")"
    if (action == "togglegroup") return "Toggle window group"
    if (action == "changegroupactive") return "Cycle group focus"
    if (action == "cyclenext") return "Cycle to next window"
    if (action == "bringactivetotop") return "Bring active window to top"
    if (action == "pseudo") return "Toggle pseudo (dwindle)"
    if (action == "togglesplit") return "Toggle split (dwindle)"
    if (action == "layoutmsg") {
        if (args == "removemaster") return "Master: remove from master stack"
        if (args == "addmaster") return "Master: add to master stack"
        if (args == "cyclenext") return "Master: cycle next"
        if (args == "cycleprev") return "Master: cycle previous"
        if (args == "swapwithmaster") return "Master: swap with master"
        return "Master layout: " args
    }
    if (action == "exec") {
        if (args ~ /cursor:zoom.*factor \* 2/) return "Zoom in (cursor magnifier)"
        if (args ~ /cursor:zoom.*factor \/ 2/) return "Zoom out (cursor magnifier)"
        if (args ~ /splitratio/)               return "Set master split ratio"
        if (args ~ /workspaceopt allfloat/)    return "Float all windows on workspace"
        if (args ~ /MediaCtrl.*--pause/)       return "Play / pause media"
        if (args ~ /MediaCtrl.*--nxt/)         return "Next media track"
        if (args ~ /MediaCtrl.*--prv/)         return "Previous media track"
        if (args ~ /MediaCtrl.*--stop/)        return "Stop media"
        if (args ~ /Volume.*--toggle-mic/)     return "Toggle microphone mute"
        if (args ~ /Volume.*--toggle/)         return "Toggle mute"
        if (args ~ /Volume.*--inc/)            return "Volume up"
        if (args ~ /Volume.*--dec/)            return "Volume down"
    }
    return ""
}

function describe(action, args, comment,    d) {
    d = derive(action, args)
    # For non-exec actions, the canonical derived description beats the comment
    # (comments like "dwindle" or "only works on dwindle layout" are side notes).
    if (d != "" && action != "exec") return d
    # For exec actions, prefer the user-written comment, else derived, else raw.
    if (comment != "" && comment !~ /^NOTE:/) return comment
    if (d != "") return d
    return action (args == "" ? "" : " " args)
}

/^bind[a-z]*[[:space:]]*=/ {
    line = $0
    sub(/^[^=]*=[[:space:]]*/, "", line)

    # split off trailing # comment (only when # is preceded by whitespace, to avoid URLs like https://)
    comment = ""
    if (match(line, /[[:space:]]+#[[:space:]]*/)) {
        comment = substr(line, RSTART + RLENGTH)
        sub(/[[:space:]]+$/, "", comment)
        line = substr(line, 1, RSTART - 1)
    }
    sub(/[[:space:]]+$/, "", line)

    n = split(line, parts, /[[:space:]]*,[[:space:]]*/)
    if (n < 2) next

    mods = parts[1]
    key  = parts[2]
    action = (n >= 3) ? parts[3] : ""
    args = ""
    for (i = 4; i <= n; i++) args = args ((i == 4) ? "" : ", ") parts[i]

    sub(/^[[:space:]]+/, "", action); sub(/[[:space:]]+$/, "", action)
    sub(/^[[:space:]]+/, "", args);   sub(/[[:space:]]+$/, "", args)
    sub(/^[[:space:]]+/, "", key);    sub(/[[:space:]]+$/, "", key)

    # normalize modifiers
    gsub(/\$mainMod/, "Super", mods)
    sub(/^[[:space:]]+/, "", mods); sub(/[[:space:]]+$/, "", mods)
    gsub(/[[:space:]]+/, " + ", mods)

    key = pretty_key(key)
    combo = (mods == "") ? key : mods " + " key

    cat  = categorize(action, args, comment)
    desc = describe(action, args, comment)

    printf "%s\t%s\t%s\n", cat, combo, desc
}
' "${files[@]}")

# Sort by category + combo, then format with dynamic column widths
# (two-pass awk: first pass measures max widths, second pass prints aligned).
display=$(printf '%s\n' "$parsed" \
    | sort -t $'\t' -k1,1 -k2,2 \
    | awk -F'\t' '
        {
            rows[NR] = $0
            cat = "[" $1 "]"
            if (length(cat)  > w1) w1 = length(cat)
            if (length($2)   > w2) w2 = length($2)
        }
        END {
            for (i = 1; i <= NR; i++) {
                n = split(rows[i], f, "\t")
                printf "%-*s  %-*s  %s\n", w1, "[" f[1] "]", w2, f[2], f[3]
            }
        }')

if [[ -z "$display" ]]; then
    echo "no keybinds found."
    exit 1
fi

# Adapt rofi layout to the focused monitor.
# fixed-height: true keeps the window the same size when a filter shrinks
# the bind list (otherwise the listview collapses to fit fewer rows).
focused_width=$(hyprctl monitors -j 2>/dev/null \
    | jq -r 'first(.[] | select(.focused == true) | .width) // empty')
if [[ "$focused_width" =~ ^[0-9]+$ ]] && (( focused_width >= 2560 )); then
    layout='listview { columns: 2; lines: 10; fixed-height: true; }'
else
    layout='listview { columns: 1; lines: 6;  fixed-height: true; }'
fi

# Cache the formatted listview to a temp file so the script-mode
# invocations (which run as separate processes spawned by rofi) can
# read it without re-parsing.
cache=$(mktemp /tmp/keybinds.XXXXXX)
trap 'rm -f "$cache"' EXIT
printf '%s\n' "$display" > "$cache"
export KEYBINDS_CACHE="$cache"

# Hotkey → -kb-custom-N flag wiring.
#   Alt+0     → custom-10 → All
#   Alt+1..9  → custom-1..9 → cats 1..9
#   Alt+minus → custom-11 → cat 10
#   Alt+equal → custom-12 → cat 11
hotkey_kb=("Alt+0" "Alt+1" "Alt+2" "Alt+3" "Alt+4" "Alt+5" "Alt+6" "Alt+7" "Alt+8" "Alt+9" "Alt+minus" "Alt+equal")
custom_n=(10 1 2 3 4 5 6 7 8 9 11 12)

mapfile -t cat_array < <(printf '%s\n' "$display" | sed -n 's/^\[\([^]]*\)\].*/\1/p' | sort -u)
nslots=$((${#cat_array[@]} + 1))
(( nslots > ${#hotkey_kb[@]} )) && nslots=${#hotkey_kb[@]}

kb_flags=()
for ((i = 0; i < nslots; i++)); do
    kb_flags+=("-kb-custom-${custom_n[$i]}" "${hotkey_kb[$i]}")
done

# Launch rofi with this script as a custom modi. Rofi keeps the window
# open and re-invokes the script for selections / custom keybindings.
rofi -show keybinds -modi "keybinds:$(realpath "$0")" \
    -config "$rofi_theme" \
    -theme-str "$layout" \
    -kb-cancel "Escape,Super+q" \
    "${kb_flags[@]}"
