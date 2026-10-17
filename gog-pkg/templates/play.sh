#!/bin/sh
set -eu
HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
exec /usr/bin/open "$HERE/game/Installed.app"
