#!/bin/sh
alias ln='ln -Tsrfv'

ln dunst ~/.config/dunst
ln hypr ~/.config/hypr
ln kitty ~/.config/kitty
ln walker ~/.config/walker
ln waybar ~/.config/waybar
ln elephant ~/.config/elephant
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
