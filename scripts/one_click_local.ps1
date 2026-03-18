param(
  [int]$Port = 8793,
  [string]$Folder = "build/web",
  [switch]$Rebuild,
  [switch]$Clean,
  [switch]$SkipBuild,
  [switch]$NoOpen
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $PSScriptRoot ".pwa_local_server.pid"

function Get-UrlStatus([string]$url) {
  for ($i = 0; $i -lt 4; $i++) {
    try {
      $res = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 6
      return [int]$res.StatusCode
    } catch {
      Start-Sleep -Milliseconds 350
    }
  }
  return -1
}

function Stop-ExistingPreviewServer([string]$pidPath) {
  if (-not (Test-Path -LiteralPath $pidPath)) { return }
  try {
    $raw = (Get-Content -LiteralPath $pidPath -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace($raw)) {
      Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
      return
    }
    $oldPid = [int]$raw
    $oldProc = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
    if ($oldProc) {
      Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
    }
  } finally {
    Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
  }
}

function Start-PreviewServer([int]$basePort, [string]$folder) {
  for ($p = $basePort; $p -lt ($basePort + 20); $p++) {
    $proc = Start-Process -FilePath "python" -ArgumentList @("-m", "http.server", "$p", "--directory", $folder) -PassThru -WindowStyle Hidden
    Start-Sleep -Milliseconds 900

    if ($proc.HasExited) {
      continue
    }

    $status = Get-UrlStatus "http://127.0.0.1:$p/index.html"
    if ($status -eq 200) {
      return @{
        Process = $proc
        Port = $p
      }
    }

    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
  }

  throw "Unable to start preview server. Ports $basePort-$($basePort + 19) are unavailable."
}

Set-Location $projectRoot

Write-Host "[Pickup] One-click deploy started..." -ForegroundColor Cyan

Stop-ExistingPreviewServer -pidPath $pidFile

if ($SkipBuild) {
  Write-Host "[Pickup] Skip build enabled, using existing output." -ForegroundColor DarkGray
} elseif ($Rebuild -or -not (Test-Path -LiteralPath $Folder)) {
  $buildScript = Join-Path $PSScriptRoot "build_pwa.ps1"
  if ($Clean) {
    & $buildScript -Clean
  } else {
    & $buildScript
  }
} else {
  Write-Host "[Pickup] Existing build found, skip rebuild. Use -Rebuild to force." -ForegroundColor DarkGray
}

if (-not (Test-Path -LiteralPath $Folder)) {
  throw "Build output missing: $Folder"
}

$server = Start-PreviewServer -basePort $Port -folder $Folder
$url = "http://127.0.0.1:$($server.Port)"

Set-Content -LiteralPath $pidFile -Value "$($server.Process.Id)" -Encoding ASCII

Write-Host "[Pickup] Deployed locally." -ForegroundColor Green
Write-Host "[Pickup] URL: $url" -ForegroundColor Green
Write-Host "[Pickup] PID: $($server.Process.Id)" -ForegroundColor DarkGray

if (-not $NoOpen) {
  try {
    Start-Process $url | Out-Null
  } catch {
    Write-Host "[Pickup] Auto-open browser skipped: $($_.Exception.Message)" -ForegroundColor Yellow
  }
}
