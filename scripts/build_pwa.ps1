param(
  [switch]$Clean
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "[Pickup] Building PWA (offline-first strategy)..." -ForegroundColor Cyan

if ($Clean) {
  flutter clean
}

flutter pub get
flutter build web --release --pwa-strategy=offline-first --no-tree-shake-icons

$fallbackFontSource = "build/web/assets/fonts/MaterialIcons-Regular.otf"
$fallbackFontDest = "build/web/MaterialIcons-Regular.otf"
if (Test-Path -LiteralPath $fallbackFontSource) {
  Copy-Item -LiteralPath $fallbackFontSource -Destination $fallbackFontDest -Force
}

$fallbackLogoSourcePng = "build/web/assets/assets/branding/pickuplogo.png"
$fallbackLogoSourceJpg = "build/web/assets/assets/branding/pickuplogo.jpg"
if (Test-Path -LiteralPath $fallbackLogoSourcePng) {
  Copy-Item -LiteralPath $fallbackLogoSourcePng -Destination "build/web/pickuplogo.png" -Force
} elseif (Test-Path -LiteralPath $fallbackLogoSourceJpg) {
  Copy-Item -LiteralPath $fallbackLogoSourceJpg -Destination "build/web/pickuplogo.jpg" -Force
}

Write-Host "[Pickup] Build complete: build/web" -ForegroundColor Green
