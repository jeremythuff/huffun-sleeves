#!/bin/bash
# Starts {{title|sh_dq}} with the bundled Wine {{rt.wine.version|raw}}. Written by huffun.
# game/ holds the game's archived original files; prefix/ is this game's Windows
# environment (settings and saves), created on the first start.
# bash 3.2. Does not change anything outside this folder.
set -u
HERE="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
cd "$HERE" || exit 1
# A downloaded folder is quarantined; this one came from your huffun
# library, so let macOS open the bundled Wine.
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null || true
case "$HERE" in
  */AppTranslocation/*)
    printf '%s\n' "macOS opened a temporary copy. Move this folder and run it again."
    exit 1
    ;;
esac
# This Wine is an Intel build; Apple silicon runs it through Rosetta 2.
if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
  printf '%s\n' "Wine needs Rosetta 2. Install it, then open this again:" \
    "  softwareupdate --install-rosetta --agree-to-license"
  exit 1
fi
WINE="$HERE/{{rt.wine.program|raw}}"
GAME="$HERE/game/{{params.exe|sh_dq}}"
[ -f "$WINE" ] || { printf '%s\n' "Missing the bundled Wine."; exit 1; }
{{#if params.installer}}
IFS= read -r PRIMARY < "$HERE/game/.huffun-program" || { echo "Install the offline payload first."; exit 1; }
case "/$PRIMARY/" in */../*|*/./*|*//*) echo "Unsafe primary program"; exit 1 ;; esac
GAME="$HERE/game/$PRIMARY"
{{/if}}
[ -f "$GAME" ] || { printf '%s\n' "Missing the game."; exit 1; }
export WINEPREFIX="$HERE/prefix"
export WINEDEBUG=-all
if [ -f "$HERE/.huffun-directdraw" ]; then
  export WINEDLLOVERRIDES="ddraw=b"
fi
if [ ! -f "$WINEPREFIX/system.reg" ]; then
  printf '%s\n' "Setting up Wine for this game (first start only, about a minute)..."
  "$WINE" wineboot --init || { printf '%s\n' "Wine could not set up its environment."; exit 1; }
fi
if [ -f "$HERE/.huffun-directdraw" ]; then
  "$WINE" reg add "HKCU\\Software\\Wine\\Direct3D" /v renderer /t REG_SZ /d gdi /f >/dev/null 2>&1 || exit 1
fi
cd "$(dirname "$GAME")" || exit 1
# Steam starts its DOS games through a batch file that runs DOSBox.
case "$GAME" in
  *.bat|*.BAT|*.Bat) exec "$WINE" cmd /c "$(basename "$GAME")" ;;
  *) exec "$WINE" "$(basename "$GAME")" ;;
esac
