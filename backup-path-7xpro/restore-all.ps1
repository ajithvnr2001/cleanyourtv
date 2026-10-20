# Standalone full restore script for SPPL PATH_7XPRO (LEDTV32HD, Android TV 9)
# Re-enables every package that was enabled in the initial backup before any debloat,
# restores com.google.android.tvlauncher as the default Home screen, and resets Private DNS.
param(
    [string]$TvHost = $(if ($env:TV_HOST) { $env:TV_HOST } else { "192.168.29.239" })
)
$ErrorActionPreference = 'Stop'
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
$env:TV_HOST = $TvHost
$repo = Split-Path -Parent $PSScriptRoot
$py = Join-Path $repo 'tools\venv\Scripts\python.exe'
$tv = Join-Path $repo 'tools\tv.py'

$enabledPkgs = Get-Content (Join-Path $PSScriptRoot 'packages-enabled.txt') |
    ForEach-Object { ($_ -replace '^package:', '').Trim() } |
    Where-Object { $_ }

$cmds = @()
foreach ($pkg in $enabledPkgs) {
    $cmds += "pm enable --user 0 $pkg"
}
$cmds += "cmd package set-home-activity --user 0 com.google.android.tvlauncher/.MainActivity"
$cmds += "settings put global private_dns_mode opportunistic"

Write-Host "Restoring $($enabledPkgs.Count) originally enabled packages and stock launcher on $TvHost..."
$cmds | & $py -I $tv --batch
Write-Host "Restore complete!"
