#!/bin/bash
# Bluetooth state as one line of JSON for the Eww control center.
NONE='{"available":false,"on":false,"device":"","label":"Unavailable"}'

command -v bluetoothctl >/dev/null 2>&1 || { echo "$NONE"; exit 0; }
show=$(timeout 2 bluetoothctl show 2>/dev/null)
grep -q 'Powered:' <<<"$show" || { echo "$NONE"; exit 0; }

if grep -q 'Powered: yes' <<<"$show"; then
  dev=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3- | tr -d '"\\')
  printf '{"available":true,"on":true,"device":"%s","label":"%s"}\n' "$dev" "${dev:-On}"
else
  echo '{"available":true,"on":false,"device":"","label":"Off"}'
fi
