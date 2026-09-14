# Installs statusline.py into ~/.claude and points Claude Code's statusLine at it.
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$claudeDir = Join-Path $HOME '.claude'
New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null

$target = Join-Path $claudeDir 'statusline.py'
Copy-Item -Force (Join-Path $repo 'statusline.py') $target

$python = $null
foreach ($name in 'python', 'python3', 'py') {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if ($cmd) { $python = $cmd.Source; break }
}
if (-not $python) { throw 'Python 3 not found on PATH; install it, then re-run.' }

$settingsPath = Join-Path $claudeDir 'settings.json'
$settings = @{}
if (Test-Path $settingsPath) {
  $raw = Get-Content -Raw -Encoding UTF8 $settingsPath
  if ($raw.Trim()) { $settings = $raw | ConvertFrom-Json }
}
$command = '"' + ($python -replace '\\', '/') + '" "' + ($target -replace '\\', '/') + '"'
$statusLine = [pscustomobject]@{ type = 'command'; command = $command }
if ($settings -is [hashtable]) { $settings = [pscustomobject]$settings }
if ($settings.PSObject.Properties['statusLine']) { $settings.statusLine = $statusLine }
else { $settings | Add-Member -NotePropertyName statusLine -NotePropertyValue $statusLine }
Copy-Item -Force $settingsPath ($settingsPath + '.bak-statusline') -ErrorAction SilentlyContinue
$json = $settings | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($settingsPath, $json + "`n", (New-Object System.Text.UTF8Encoding($false)))

Write-Host "statusline.py -> $target"
Write-Host "settings.json statusLine -> $command"
Write-Host 'Restart Claude Code to see it.'
