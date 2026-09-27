#!/bin/sh
# Session started by the login screen (gtkgreet -c /etc/greetd/session.sh).
# The VT is briefly visible between the greeter quitting and Hyprland taking
# over the screen, so clear it, hide the text cursor, and keep uwsm's startup
# report off it. Hyprland itself runs as a systemd unit and logs to the journal.
printf '\033[2J\033[3J\033[H\033[?25l'
exec uwsm start hyprland-uwsm.desktop >/dev/null 2>&1
