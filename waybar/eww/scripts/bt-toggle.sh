#!/bin/bash
# Usage: bt-toggle.sh on|off  -- switches Bluetooth and refreshes the tile right away.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bluetoothctl power "$1" >/dev/null 2>&1
sleep 0.4
eww --config "$DIR" update bt="$(bash "$DIR/scripts/bluetooth.sh")" >/dev/null 2>&1
