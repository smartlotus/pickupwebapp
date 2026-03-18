param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$pidFile = Join-Path $PSScriptRoot ".pwa_local_server.pid"

if (-not (Test-Path -LiteralPath $pidFile)) {
  Write-Host "[Pickup] No running preview server record found." -ForegroundColor Yellow
  exit 0
}

$raw = (Get-Content -LiteralPath $pidFile -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($raw)) {
  Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
  Write-Host "[Pickup] PID file was empty. Cleaned." -ForegroundColor Yellow
  exit 0
}

$serverPid = [int]$raw
$proc = Get-Process -Id $serverPid -ErrorAction SilentlyContinue
if ($proc) {
  Stop-Process -Id $serverPid -Force
  Write-Host "[Pickup] Preview server stopped (PID=$serverPid)." -ForegroundColor Green
} else {
  Write-Host "[Pickup] Process $serverPid is not running." -ForegroundColor Yellow
}

Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
