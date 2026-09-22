#!/bin/bash
# Opens/closes the control center. Called by the Waybar button.
# Errors are shown as a notification and written to $XDG_RUNTIME_DIR/control-center.log

# Force a monitor by number (0, 1, ...). Leave empty to open on the monitor you clicked on.
MONITOR=""

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EWW=(eww --config "$DIR")
LOG="${XDG_RUNTIME_DIR:-/tmp}/control-center.log"

fail() {
  notify-send -u critical "Control center" "$1 (log: $LOG)" 2>/dev/null
  exit 1
}

command -v eww >/dev/null 2>&1 || fail "eww is not installed"

if "${EWW[@]}" active-windows 2>/dev/null | grep -q '^control-center:'; then
  "${EWW[@]}" close control-center cc-closer
  "${EWW[@]}" update sinks_open=false confirm=none
  exit 0
fi

# The focused monitor is the one the bar button was clicked on. Hyprland numbers monitors
# (HDMI-A-2 = 1) but Eww uses GTK's own numbering, so translate by matching screen positions.
# If that isn't possible we fall back to Hyprland's number, and finally to monitor 1.
if [ -z "$MONITOR" ] && command -v hyprctl >/dev/null 2>&1; then
  MONITOR=$(hyprctl monitors -j 2>/dev/null | GDK_BACKEND=wayland python3 -c '
import sys, json
mons = json.load(sys.stdin)
cur = next((m for m in mons if m.get("focused")), mons[0])
idx = cur["id"]
try:
    import gi
    gi.require_version("Gdk", "3.0")
    from gi.repository import Gdk
    Gdk.init([])
    display = Gdk.Display.get_default()
    for i in range(display.get_n_monitors()):
        g = display.get_monitor(i).get_geometry()
        if (g.x, g.y) == (cur["x"], cur["y"]):
            idx = i
            break
except Exception:
    pass
print(idx)
' 2>/dev/null)
fi
MONITOR="${MONITOR:-1}"

out=$("${EWW[@]}" open-many cc-closer control-center \
        --arg "cc-closer:monitor=$MONITOR" --arg "control-center:monitor=$MONITOR" 2>&1) || {
  printf '%s\n' "$out" > "$LOG"
  fail "Could not open the panel: $(printf '%s' "$out" | head -1)"
}
