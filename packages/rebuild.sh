#!/bin/bash
# Rebuild and reinstall the locally patched packages in this folder (waybar,
# xembedsniproxy) when the installed version is not the one their PKGBUILD builds.
#
# Run it after a system update has replaced the patched waybar with the repo's
# build (workspace clicks and sticky tray icons stop working), or after changing
# a PKGBUILD or patch here.
#
#   ./rebuild.sh            rebuild and install whatever is out of date
#   ./rebuild.sh -f         rebuild and install everything
#   ./rebuild.sh -n         only report what is out of date
#   ./rebuild.sh waybar     limit to the named package(s)
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

force=false
check_only=false
packages=()
for arg in "$@"; do
    case "$arg" in
        -f|--force) force=true ;;
        -n|--check) check_only=true ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*) echo "Unknown option: $arg" >&2; exit 2 ;;
        *) packages+=("${arg%/}") ;;
    esac
done
if [ ${#packages[@]} -eq 0 ]; then
    for pkgbuild in */PKGBUILD; do packages+=("$(dirname "$pkgbuild")"); done
fi

# pkgver-pkgrel that a PKGBUILD builds
pkgbuild_version() {
    (source "$1/PKGBUILD" && echo "$pkgver-$pkgrel")
}

rebuilt=()
for pkg in "${packages[@]}"; do
    if [ ! -f "$pkg/PKGBUILD" ]; then
        echo "$pkg: no PKGBUILD in $(pwd)/$pkg" >&2
        exit 1
    fi

    name=$(source "$pkg/PKGBUILD" && echo "$pkgname")
    want=$(pkgbuild_version "$pkg")
    have=$(pacman -Q "$name" 2>/dev/null | awk '{print $2}' || true)

    if [ "$have" = "$want" ] && ! $force; then
        echo "$name: $have is installed, up to date"
        continue
    fi
    echo "$name: installed ${have:-nothing}, PKGBUILD builds $want"

    # A newer upstream release in the repos means the PKGBUILD and its patches are
    # based on an old version; building it would downgrade the package.
    upstream=$(pacman -Si "$name" 2>/dev/null | awk '/^Version/ {print $3; exit}' || true)
    if [ -n "$upstream" ] && [ "${upstream%-*}" != "${want%-*}" ]; then
        echo "  note: the repos have $name $upstream, but this PKGBUILD is for ${want%-*}."
        echo "        Update pkgver, checksums and patches in $pkg/ first, or this installs the older version."
        if ! $check_only; then
            read -r -p "  Build ${want%-*} anyway? [y/N] " answer
            [[ "$answer" =~ ^[Yy]$ ]] || continue
        fi
    fi

    $check_only && continue

    (
        cd "$pkg"
        rm -f -- *.pkg.tar.zst
        makepkg --syncdeps --install --force
    )
    rebuilt+=("$name")
done

for name in "${rebuilt[@]}"; do
    case "$name" in
        waybar)
            systemctl --user restart waybar
            echo "waybar: restarted"
            ;;
        xembedsniproxy)
            echo "xembedsniproxy: installed. The running one is left alone, because restarting it"
            echo "  while a Wine app is open breaks that app's tray icon until the app is restarted."
            echo "  The new build is used from your next login."
            ;;
    esac
done
