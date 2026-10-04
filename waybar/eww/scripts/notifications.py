#!/usr/bin/env python3
"""Prints dunst's most recent notifications as a JSON list for the Eww notifications panel.

Reads `dunstctl history` (newest first) and keeps the last LIMIT entries. Dunst only
moves a notification into its history once it has left the screen.
"""
import html
import json
import re
import subprocess
import time

LIMIT = 10
BODY_MAX = 160


def plain(text):
    """Dunst bodies may carry Pango/HTML markup; show them as plain text."""
    text = re.sub(r"<[^>]+>", "", text or "")
    return re.sub(r"\s+", " ", html.unescape(text)).strip()


def main():
    try:
        out = subprocess.run(["dunstctl", "history"], capture_output=True, text=True, timeout=3).stdout
        history = json.loads(out)["data"][0]
    except Exception:
        history = []

    # Dunst timestamps are microseconds on the monotonic clock, not wall-clock time.
    offset = time.time() - time.monotonic()
    items = []
    for n in history[:LIMIT]:
        def field(name):
            return (n.get(name) or {}).get("data", "")

        body = plain(field("body"))
        if len(body) > BODY_MAX:
            body = body[: BODY_MAX - 1].rstrip() + "…"
        try:
            when = time.strftime("%H:%M", time.localtime(offset + int(field("timestamp")) / 1e6))
        except (TypeError, ValueError):
            when = ""
        items.append({
            "i": len(items),  # position in the list, staggers the clear animation
            "id": field("id"),
            "app": plain(field("appname")),
            "summary": plain(field("summary")),
            "body": body,
            "time": when,
        })
    print(json.dumps(items))


if __name__ == "__main__":
    main()
