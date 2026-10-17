$ErrorActionPreference = 'Stop'
$installer = Join-Path (Join-Path $env:HUFFUN_GAME_DIR 'game') $args[0]
$destination = Join-Path $env:HUFFUN_GAME_DIR 'installed'
$p = Start-Process -FilePath $installer -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/SP-',('/DIR="'+$destination+'"')) -Wait -PassThru
if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { throw "Offline installer failed: $($p.ExitCode)" }
