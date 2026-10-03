#!/bin/sh
# Copies the system-installed KvArcDark.svg (shipped with the kvantum
# package) into place as RiceDark.svg. Not tracked in git -- it's the
# upstream package asset, just re-copied under our theme name so our
# tweaked RiceDark.kvconfig (symlinked from this repo) can use it.
set -e

SRC="$(find /usr/share/Kvantum /usr/share/kvantum -iname 'KvArcDark.svg' 2>/dev/null | head -1)"
if [ -z "$SRC" ]; then
  echo "install.sh: couldn't find KvArcDark.svg -- is kvantum installed?" >&2
  exit 1
fi

mkdir -p ~/.config/Kvantum/RiceDark
cp -v "$SRC" ~/.config/Kvantum/RiceDark/RiceDark.svg
