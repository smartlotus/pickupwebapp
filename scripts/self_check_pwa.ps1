param(
  [string]$Folder = "build/web",
  [int]$Port = 8791
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $Folder)) {
  throw "Folder not found: $Folder . Please run build first."
}

function Get-UrlStatus([string]$url) {
  for ($i = 0; $i -lt 4; $i++) {
    try {
      $res = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 8
      return [int]$res.StatusCode
    } catch {
      Start-Sleep -Milliseconds 400
    }
  }
  return -1
}

$server = $null
try {
  $server = Start-Process -FilePath "python" -ArgumentList @("-m", "http.server", "$Port", "--directory", $Folder) -PassThru -WindowStyle Hidden
  Start-Sleep -Seconds 2

  $targets = @(
    "http://127.0.0.1:$Port/index.html",
    "http://127.0.0.1:$Port/flutter_bootstrap.js",
    "http://127.0.0.1:$Port/main.dart.js",
    "http://127.0.0.1:$Port/manifest.json",
    "http://127.0.0.1:$Port/version.json"
  )

  $failed = @()
  foreach ($url in $targets) {
    $code = Get-UrlStatus $url
    if ($code -ne 200) {
      $failed += "$url => $code"
    } else {
      Write-Host "[OK] $url" -ForegroundColor Green
    }
  }

  if ($failed.Count -gt 0) {
    Write-Host "[Pickup] Self-check failed:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
  }

  Write-Host "[Pickup] Self-check passed." -ForegroundColor Cyan
  Write-Host "[Pickup] Open in browser: http://127.0.0.1:$Port" -ForegroundColor Cyan
}
finally {
  if ($server -and -not $server.HasExited) {
    Stop-Process -Id $server.Id -Force
  }
}
