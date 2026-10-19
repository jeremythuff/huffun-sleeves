@echo off
rem Starts {{title|cmd_dq}} as GOG's installer laid it out. Written by huffun.
rem game\ holds the installer and the files it extracted; the install step
rem recorded GOG's primary program in game\.huffun-program.
setlocal
set "HERE=%~dp0"
set "GAME=%HERE%game"
if not exist "%GAME%\.huffun-program" (
  echo The game was not extracted. Install it again from its page in huffun.
  pause
  exit /b 1
)
set /p PROGRAM=<"%GAME%\.huffun-program"
set "ARGS="
if exist "%GAME%\.huffun-arguments" set /p ARGS=<"%GAME%\.huffun-arguments"
set "WORKDIR="
if exist "%GAME%\.huffun-workdir" set /p WORKDIR=<"%GAME%\.huffun-workdir"
if defined WORKDIR (
  cd /d "%GAME%\%WORKDIR%"
) else (
  for %%F in ("%GAME%\%PROGRAM%") do cd /d "%%~dpF"
)
start "" "%GAME%\%PROGRAM%" %ARGS%
