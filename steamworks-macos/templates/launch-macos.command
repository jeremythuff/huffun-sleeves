#!/bin/bash
# Opens {{title|sh_dq}}. The Steamworks library in this download is already the pinned emulator.
# Marks the game executable, clears quarantine, and ad-hoc signs the library and the protobuf
# library it loads from beside itself (runtime Vent 2). The app is re-signed
# only when its executable enforces library validation (hardened runtime or library-validation
# without the disable-library-validation entitlement); otherwise it keeps its own signature.
# Signing holds the emulator's settings and saves in .vent-hold, since codesign rejects them
# inside a bundle's code folders, and puts them back afterwards.
# bash 3.2. Does not change anything outside this folder.
set -u
HERE="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
cd "$HERE" || exit 1
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null || true
case "$HERE" in
  */AppTranslocation/*)
    printf '%s\n' "macOS opened a temporary copy. Move this folder and run it again."
    exit 1
    ;;
esac
APP="$HERE/game/{{params.app|sh_dq}}"
EXE="$HERE/game/{{params.exe|sh_dq}}"
LIB="$HERE/game/{{params.steamlib|sh_dq}}"
LIBDIR="$(dirname "$LIB")"
PB="$LIBDIR/libprotobuf-lite.3.21.12.0.dylib"
HOLD="$HERE/.vent-hold"
SIDE="steam_appid.txt local_save.txt steam_settings saves"
[ -d "$APP" ] || { printf '%s\n' "Missing the game."; exit 1; }
[ -f "$LIB" ] || { printf '%s\n' "Missing the emulator library."; exit 1; }
[ -f "$PB" ] || { printf '%s\n' "Missing the emulator's protobuf library."; exit 1; }
chmod 755 "$EXE" "$LIB" "$PB" || exit 1
export SteamAppId="{{params.appid|sh_dq}}"
export SteamGameId="$SteamAppId"
export SteamOverlayGameId="$SteamAppId"

# Puts held files back without replacing anything already there.
restore() {
  [ -d "$HOLD" ] || return 0
  for f in $SIDE; do
    if [ -e "$HOLD/$f" ] && [ ! -e "$LIBDIR/$f" ]; then
      mv "$HOLD/$f" "$LIBDIR/$f" || return 1
    fi
  done
  rmdir "$HOLD" 2>/dev/null || {
    printf '%s\n' "Some files are still in $HOLD; move them back into $LIBDIR."
    return 1
  }
}
# A run interrupted while signing left its files in the hold.
restore || exit 1

# Hold the settings and saves aside while signing: when the library is a bundle's main
# program (Graveyard Keeper's steam_api.bundle), codesign signs that bundle and rejects
# the non-code files beside it in Contents/MacOS. Version 9 signed with them in place.
mkdir "$HOLD" || exit 1
trap 'restore' EXIT
trap 'exit 1' HUP INT TERM
for f in $SIDE; do
  if [ -e "$LIBDIR/$f" ]; then
    mv "$LIBDIR/$f" "$HOLD/$f" || exit 1
  fi
done

# The protobuf library first: when the emulator is a bundle's main program, signing it seals
# the bundle, and codesign needs the code beside it signed already.
codesign --force --sign - "$PB" || { printf '%s\n' "Could not sign the protobuf library."; exit 1; }
codesign --force --sign - "$LIB" || { printf '%s\n' "Could not sign the library."; exit 1; }

# Library validation applies to hardened-runtime or library-validation executables, unless
# their entitlements disable it. Version 7 re-signed every app and failed on data files
# that apps such as Aseprite keep in Contents/MacOS.
enforces_lv() {
  codesign --display --verbose "$EXE" 2>&1 | grep -Eq 'flags=0x[0-9a-f]+\([^)]*(runtime|library-validation)' || return 1
  codesign --display --entitlements - "$EXE" 2>/dev/null | grep -q 'com.apple.security.cs.disable-library-validation' && return 1
  return 0
}
if enforces_lv; then
  dir="$LIBDIR"
  while [ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$HERE" ]; do
    name="$(basename "$dir")"
    case "$name" in
      *.bundle|*.framework|*.app)
        if codesign --display "$dir" >/dev/null 2>&1; then
          codesign --force --sign - "$dir" || {
            printf '%s\n' "Could not sign $name. This game checks the libraries it loads, so it cannot use the emulator."
            exit 1
          }
        fi
        ;;
    esac
    dir="$(dirname "$dir")"
  done
fi
restore || exit 1
trap - EXIT
open "$APP"
