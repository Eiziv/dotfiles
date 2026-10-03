#!/bin/sh
alias ln='ln -Tsrfv'

ln dunst ~/.config/dunst
ln hypr ~/.config/hypr
ln kitty ~/.config/kitty
ln walker ~/.config/walker
ln waybar ~/.config/waybar
ln elephant ~/.config/elephant
ln qt6ct ~/.config/qt6ct
mkdir -vp ~/.config/Kvantum
ln kvantum/kvantum.kvconfig ~/.config/Kvantum/kvantum.kvconfig
mkdir -vp ~/.config/Kvantum/RiceDark
ln kvantum/RiceDark.kvconfig ~/.config/Kvantum/RiceDark/RiceDark.kvconfig
sh kvantum/install.sh
ln kde/kdeglobals ~/.config/kdeglobals
ln nvim ~/.config/nvim
if [ -f ~/.config/mozilla/firefox/profiles.ini ]; then
  profile="$(yq -r '[to_entries[] | select(.key | test("^Install"))][0].value.Default' ~/.config/mozilla/firefox/profiles.ini)"
  profilePath=~/.config/mozilla/firefox/"$profile"
  mkdir -vp "$profilePath/chrome"
  ln firefox/userChrome.css "$profilePath/chrome/userChrome.css"
  ln firefox/user.js "$profilePath/user.js"
else
  echo "Warning: Firefox profiles.ini not found, start Firefox once and rerun the script." >&2
fi

# Login screen (greetd). The greeter runs as its own user and can't read
# ~/git, so these are copied rather than symlinked; rerun after changing them.
sudo install -m644 greetd/config.toml greetd/hyprland.lua greetd/hyprpaper.conf greetd/style.css /etc/greetd/
sudo install -m755 greetd/session.sh /etc/greetd/session.sh
sudo install -Dm644 hypr/wallpaper.jpg /etc/greetd/wallpapers/wallpaper.jpg
sudo install -m644 greetd/99_greeter-cursor.gschema.override /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
