#!/bin/bash
# Launches {{title|sh_dq}} in RetroArch with the Snes9x core. Written by huFFuη.
set -eu
HERE="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
cd "$HERE" || exit 1
xattr -dr com.apple.quarantine "$HERE" 2>/dev/null || true
mkdir -p "$HERE/saves" "$HERE/states"
exec "$HERE/{{rt.retroarch.program|raw}}" \
  -L "$HERE/{{rt.snes9x.program|raw}}" \
  "$HERE/rom/{{params.rom|sh_dq}}" \
  --appendconfig "$HERE/retroarch.cfg"
