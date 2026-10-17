@echo off
rem Starts {{title|cmd_dq}} with the bundled ScummVM {{rt.scummvm.version|raw}}. Written by huffun.
rem game\ holds the game's archived original files; saves go to saves\.
setlocal
set "HERE=%~dp0"
if not exist "%HERE%saves" mkdir "%HERE%saves"
start "" "%HERE%{{rt.scummvm.program|win|raw}}" --config="%HERE%scummvm.ini" --path="%HERE%game" --savepath="%HERE%saves" huffun-game
