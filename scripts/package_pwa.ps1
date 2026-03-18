param(
  [switch]$Rebuild,
  [string]$OutDir = "dist",
  [string]$NamePrefix = "pickup-pwa"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$webDir = Join-Path $projectRoot "build/web"
$outDirPath = Join-Path $projectRoot $OutDir

if ($Rebuild) {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_pwa.ps1")
}

if (-not (Test-Path -LiteralPath $webDir)) {
  throw "Folder not found: $webDir . Please run build first."
}

if (-not (Test-Path -LiteralPath $outDirPath)) {
  New-Item -ItemType Directory -Path $outDirPath | Out-Null
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$zipPath = Join-Path $outDirPath "$NamePrefix-$stamp.zip"
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Push-Location $webDir
try {
  tar -a -c -f $zipPath *
}
finally {
  Pop-Location
}

Write-Host "[Pickup] Package complete: $zipPath" -ForegroundColor Green
Get-Item -LiteralPath $zipPath | Select-Object FullName,Length,LastWriteTime
