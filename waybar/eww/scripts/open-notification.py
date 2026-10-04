#!/usr/bin/env python3
"""Click on an entry in the Eww notifications panel: go to the app that sent it.

Usage: open-notification.py <dunst notification id>

Focuses the sending app's window (matched by app name against Hyprland's window
classes and titles), removes the entry from dunst's history and closes the panel.
If no window of that app is open, nothing happens and the entry stays.

Dunst can't re-run the app's own action here: once a notification has left the
screen it has been reported to the app as closed, and dunst no longer signals
actions for it. That only works by clicking the pop-up while it is showing.

Only the id comes from the panel; the app name is looked up in dunst's history, so
text chosen by whoever sent the notification never reaches a shell.
"""
import json
import os
import subprocess
import sys

DIR = os.path.dirname(os.path.abspath(__file__))


def run(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=3).stdout
    except Exception:
        return ""


def app_of(notification_id):
    try:
        history = json.loads(run("dunstctl", "history"))["data"][0]
    except Exception:
        return ""
    for n in history:
        if (n.get("id") or {}).get("data") == notification_id:
            return ((n.get("appname") or {}).get("data") or "").strip()
    return ""


def find_window(app):
    """Best matching window for an app name, preferring the most recently focused."""
    app = app.lower()
    if not app:
        return None
    try:
        clients = json.loads(run("hyprctl", "clients", "-j"))
    except Exception:
        return None

    def score(client):
        names = [(client.get("class") or "").lower(), (client.get("initialClass") or "").lower()]
        if app in names:
            return 3
        if any(name and (app in name or name in app) for name in names):
            return 2
        if app in (client.get("title") or "").lower():
            return 1
        return 0

    matches = [c for c in clients if c.get("mapped", True) and score(c) > 0]
    if not matches:
        return None
    matches.sort(key=lambda c: (-score(c), c.get("focusHistoryID", 1 << 30)))
    return matches[0]["address"]


def main():
    try:
        notification_id = int(sys.argv[1])
    except (IndexError, ValueError):
        return 2

    address = find_window(app_of(notification_id))
    if not address:
        return 1

    subprocess.run(["bash", os.path.join(DIR, "toggle.sh"), "close"])
    subprocess.run(["hyprctl", "dispatch", f'hl.dsp.focus({{ window = "address:{address}" }})'],
                   capture_output=True)
    subprocess.run(["dunstctl", "history-rm", str(notification_id)])
    return 0


if __name__ == "__main__":
    sys.exit(main())
