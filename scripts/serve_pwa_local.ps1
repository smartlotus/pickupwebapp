param(
  [int]$Port = 8787,
  [string]$Folder = "build/web"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $Folder)) {
  throw "Folder not found: $Folder . Please run build first."
}

Write-Host "[Pickup] Serving $Folder at http://127.0.0.1:$Port" -ForegroundColor Cyan
Write-Host "[Pickup] Press Ctrl+C to stop." -ForegroundColor DarkGray

python -m http.server $Port --directory $Folder
