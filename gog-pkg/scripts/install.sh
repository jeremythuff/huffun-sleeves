#!/bin/sh
set -eu
ROOT=$HUFFUN_GAME_DIR
WORK=$(mktemp -d "$ROOT/.huffun-package.XXXXXX")
/usr/sbin/pkgutil --expand-full "$ROOT/game/$1" "$WORK/expanded"
find "$WORK/expanded" -type d -name '*.app' -prune > "$WORK/apps"
[ "$(wc -l < "$WORK/apps" | tr -d ' ')" = 1 ] || { echo 'Package must contain exactly one application' >&2; exit 1; }
IFS= read -r APP < "$WORK/apps"
PROGRAM=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")
case "$PROGRAM" in ''|*/*|*..*) echo 'Unsafe bundle program' >&2; exit 1 ;; esac
FILE=$(LC_ALL=C /usr/bin/file -b "$APP/Contents/MacOS/$PROGRAM")
case "$FILE" in *x86_64*|*arm64*|*script*) ;; *) echo 'The installed app needs an unsupported CPU' >&2; exit 1 ;; esac
case "$(uname -m):$FILE" in *:*script*) ;; x86_64:*x86_64*) ;; x86_64:*) echo 'This app requires an Apple silicon Mac' >&2; exit 1 ;; arm64:*arm64*) ;; arm64:*) /usr/bin/arch -x86_64 /usr/bin/true || { echo 'This app requires Rosetta'; exit 1; } ;; esac
[ ! -e "$ROOT/game/Installed.app" ] || { echo 'Installed.app already exists' >&2; exit 1; }
mv "$APP" "$ROOT/game/Installed.app"
rm -rf "$WORK"
