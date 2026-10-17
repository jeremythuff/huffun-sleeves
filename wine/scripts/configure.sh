#!/bin/sh
set -eu
if [ "$1" = yes ]; then printf "%s\n" software > "$HUFFUN_GAME_DIR/.huffun-directdraw"; fi
