$ErrorActionPreference = 'Stop'
# Extracts the selected offline installer into game\ with the pinned
# innoextract, as on Mac, instead of running GOG's setup program: no
# administrator prompt, no registry entries, nothing outside the install
# folder. The setup and its slices stay for reinstalling. Then records GOG's
# primary play task for "Play <title>.cmd".
$root = $env:HUFFUN_GAME_DIR
$game = Join-Path $root 'game'
$setup = Join-Path $game $args[0]
if (-not (Test-Path -LiteralPath $setup -PathType Leaf)) { throw 'Selected installer is missing' }
$tool = Join-Path $root 'innoextract\innoextract.exe'
if (-not (Test-Path -LiteralPath $tool -PathType Leaf)) { throw 'The innoextract runtime is missing' }

$work = Join-Path $root ('.huffun-extract.' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $work | Out-Null
try {
  & $tool --silent --gog --output-dir $work $setup
  if ($LASTEXITCODE -ne 0) { throw "innoextract stopped with code $LASTEXITCODE" }
  # Application files go beside the setup; installer scratch does not.
  $items = @(Get-ChildItem -LiteralPath $work -Force |
      Where-Object { @('tmp', '__redist', 'commonappdata', 'app') -notcontains $_.Name })
  $app = Join-Path $work 'app'
  if (Test-Path -LiteralPath $app) { $items += @(Get-ChildItem -LiteralPath $app -Force) }
  foreach ($item in $items) {
    $destination = Join-Path $game $item.Name
    if ($item.PSIsContainer) {
      robocopy $item.FullName $destination /E /MOVE /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
      # robocopy: 0-7 copied, 8 and above failed.
      if ($LASTEXITCODE -ge 8) { throw "Copying $($item.Name) failed with code $LASTEXITCODE" }
    } else {
      Move-Item -LiteralPath $item.FullName -Destination $destination -Force
    }
  }
} finally {
  Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}

function Test-Inside([string] $path) {
  if (-not $path) { return $false }
  if ([System.IO.Path]::IsPathRooted($path) -or $path -match '[\r\n\0:]') { return $false }
  foreach ($part in ($path -split '\\')) {
    if (-not $part -or $part -eq '.' -or $part -eq '..') { return $false }
  }
  return $true
}

$info = Get-ChildItem -LiteralPath $game -Filter 'goggame-*.info' -File | Select-Object -First 1
if (-not $info) { throw 'No primary play-task metadata was extracted' }
$value = Get-Content -LiteralPath $info.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
$tasks = @($value.playTasks | Where-Object {
    $_.isPrimary -and $_.path -and (-not $_.type -or $_.type -eq 'FileTask') })
if ($tasks.Count -ne 1) { throw 'Choose a release with one primary executable' }
$task = $tasks[0]
$program = ([string] $task.path) -replace '/', '\'
if (-not (Test-Inside $program)) { throw 'Unsafe primary executable path' }
if (-not (Test-Path -LiteralPath (Join-Path $game $program) -PathType Leaf)) {
  throw 'The extracted primary executable is missing'
}
$arguments = [string] $task.arguments
# The launcher passes them to Command Prompt's start: no other commands.
if ($arguments -match '[&|<>^%!\r\n]') { throw 'The play arguments use characters huffun does not pass on' }
$workdir = ([string] $task.workingDir) -replace '/', '\'
if ($workdir -and -not (Test-Inside $workdir)) { throw 'Unsafe working folder' }

Set-Content -LiteralPath (Join-Path $game '.huffun-program') -Value $program -NoNewline -Encoding Default
if ($arguments) { Set-Content -LiteralPath (Join-Path $game '.huffun-arguments') -Value $arguments -NoNewline -Encoding Default }
if ($workdir) { Set-Content -LiteralPath (Join-Path $game '.huffun-workdir') -Value $workdir -NoNewline -Encoding Default }
exit 0
