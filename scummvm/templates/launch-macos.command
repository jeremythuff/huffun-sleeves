#!/bin/bash
# Starts {{title|sh_dq}} with the bundled ScummVM {{rt.scummvm.version|raw}}. Written by huffun.
# game/ holds the game's archived original files; saves go to saves/.
set -u
HERE="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
cd "$HERE" || exit 1
# A downloaded folder is quarantined; this one came from your huffun
# library, so let macOS open the bundled ScummVM.
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null
mkdir -p "$HERE/saves"
exec "$HERE/{{rt.scummvm.program|raw}}" --config="$HERE/scummvm.ini" --path="$HERE/game" --savepath="$HERE/saves" huffun-game
