@echo off
rem Launches {{title|cmd_dq}} in RetroArch with the Snes9x core. Written by huFFuη.
setlocal
set "HERE=%~dp0"
cd /d "%HERE%"
if not exist "%HERE%saves" mkdir "%HERE%saves"
if not exist "%HERE%states" mkdir "%HERE%states"
start "" "%HERE%{{rt.retroarch.program|win|raw}}" -L "%HERE%{{rt.snes9x.program|win|raw}}" "%HERE%rom\{{params.rom|win|cmd_dq}}" --appendconfig "%HERE%retroarch.cfg"
