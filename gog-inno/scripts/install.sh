#!/bin/sh
set -eu
ROOT=$HUFFUN_GAME_DIR
[ -f "$ROOT/game/$1" ] || { echo 'Selected installer is missing' >&2; exit 1; }
WORK=$(mktemp -d "$ROOT/.huffun-extract.XXXXXX")
"$ROOT/innoextract/run" --silent --gog --output-dir "$WORK" "$ROOT/game/$1"
# Install application files; keep the original setup and slices for reinstallation.
for item in "$WORK"/*; do
  [ -e "$item" ] || continue
  case "${item##*/}" in tmp|__redist|commonappdata) continue ;; app) continue ;; esac
  cp -R "$item" "$ROOT/game/"
done
if [ -d "$WORK/app" ]; then cp -R "$WORK/app/." "$ROOT/game/"; fi
set -- "$ROOT"/game/goggame-*.info
[ -f "$1" ] || { echo 'No primary play-task metadata was extracted' >&2; exit 1; }
/usr/bin/osascript -l JavaScript -e '
ObjC.import("Foundation");
function run(argv) {
 const text=ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null));
 const value=JSON.parse(text);
 const tasks=(value.playTasks||[]).filter(t=>t.isPrimary && t.path && (!t.type || t.type==="FileTask"));
 if(tasks.length!==1) throw new Error("Choose a release with one primary executable");
 const p=tasks[0].path.replace(/\\/g,"/");
 if(p.startsWith("/") || /^[A-Za-z]:/.test(p) || /[\r\n\0]/.test(p) || p.split("/").some(s=>!s||s===".."||s===".")) throw new Error("Unsafe primary executable path");
 if(tasks[0].arguments) throw new Error("This release needs play arguments; keep using the existing installation until supported");
 return p;
}' "$1" > "$ROOT/game/.huffun-program"
IFS= read -r PROGRAM < "$ROOT/game/.huffun-program"
[ -f "$ROOT/game/$PROGRAM" ] || { echo 'The extracted primary executable is missing' >&2; exit 1; }
rm -rf "$WORK"
