#!/bin/bash
# Starts {{title|sh_dq}} with the bundled Fallout II Community Edition {{rt.fallout2ce.version|raw}}. Written by huffun.
# game/ holds the game's archived original files; the app beside them reads
# master.dat, critter.dat, and data/ from its own folder. Saves go to
# game/data/SAVEGAME. bash 3.2. Does not change anything outside this folder.
set -u
HERE="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
cd "$HERE" || exit 1
# A downloaded folder is quarantined; this one came from your huffun
# library, so let macOS open the bundled app from where it is (a
# quarantined app is moved to a temporary copy and cannot find the data).
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null || true
case "$HERE" in
  */AppTranslocation/*)
    printf '%s\n' "macOS opened a temporary copy. Move this folder and run it again."
    exit 1
    ;;
esac
APP="$HERE/game/{{params.dataRoot|sh_dq}}/Fallout II Community Edition.app"
[ -d "$APP" ] || { printf '%s\n' "Missing the bundled Fallout II Community Edition."; exit 1; }
exec open "$APP"
