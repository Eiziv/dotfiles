#!/bin/bash
# Battery of a wireless Logitech mouse (G Pro X Superlight) as one line of JSON.
# Used by the Eww control center (and by a Waybar custom module if you re-add one).
# When the mouse isn't found: "connected":false and an empty "text" (Waybar hides the module).
#
# Source 1: the kernel's HID++ driver, which exposes the mouse under
#           /sys/class/power_supply/hidpp_battery_N (the number changes between
#           reconnects, so we glob instead of hardcoding it).
# Source 2: Solaar (`solaar show`), used only if source 1 finds nothing.
#
# MOUSE_MATCH is matched (case-insensitive) against the device name.

MATCH="${MOUSE_MATCH:-superlight}"
cap=""; status=""; name=""

for d in /sys/class/power_supply/hidpp_battery_*; do
  [ -d "$d" ] || continue
  model=$(tr -d '"\\' < "$d/model_name" 2>/dev/null)
  if [ -z "$cap" ] || echo "$model" | grep -qi "$MATCH"; then
    c=$(cat "$d/capacity" 2>/dev/null)
    if [ -n "$c" ]; then
      cap=$c
      status=$(cat "$d/status" 2>/dev/null)
      name=$model
    fi
  fi
done

if [ -z "$cap" ] && command -v solaar >/dev/null 2>&1; then
  out=$(timeout 8 solaar show "$MATCH" 2>/dev/null)
  line=$(echo "$out" | grep -i 'Battery:' | head -1)
  cap=$(echo "$line" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
  status=$(echo "$line" | grep -oiE 'discharging|charging|recharging|full' | head -1)
  name="Logitech mouse (via Solaar)"
fi

if [ -z "$cap" ]; then
  echo '{"text":"","percentage":0,"class":"","tooltip":"","label":"Not connected","connected":false}'
  exit 0
fi

# Icon: 5 steps from full to empty (charging gets its own icon).
if   [ "${status,,}" = "charging" ] || [ "${status,,}" = "recharging" ]; then icon="󰂄"; class="charging"
elif [ "$cap" -gt 85 ]; then icon="󰁹"; class=""
elif [ "$cap" -gt 60 ]; then icon="󰂀"; class=""
elif [ "$cap" -gt 35 ]; then icon="󰁾";  class=""
elif [ "$cap" -gt 15 ]; then icon="󰁼";  class="warning"
else                         icon="󰂎"; class="critical"
fi

label="${cap}%"
[ "$class" = "charging" ] && label="${cap}% · charging"

printf '{"text":"%s","percentage":%s,"class":"%s","tooltip":"%s: %s%% %s","label":"%s","connected":true}\n' \
  "$icon" "$cap" "$class" "${name:-Mouse}" "$cap" "${status:+($status)}" "$label"
