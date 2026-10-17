#!/bin/sh
set -eu
if [ "$1" = yes ]; then
  printf "%s\n" software > "$HUFFUN_GAME_DIR/.huffun-directdraw"
  if [ -d "$HUFFUN_GAME_DIR/game" ]; then
    printf "%s\n" software > "$HUFFUN_GAME_DIR/game/.huffun-directdraw"
  fi
fi
