#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.4-stable}"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"
FLUTTER_ROOT="$HOME/flutter-sdk"

if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  rm -rf "$FLUTTER_ROOT"
  mkdir -p "$HOME"
  curl -fsSL "$FLUTTER_URL" -o /tmp/flutter.tar.xz
  tar -xf /tmp/flutter.tar.xz -C "$HOME"
  mv "$HOME/flutter" "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release --pwa-strategy=offline-first --no-tree-shake-icons

if [ -f "build/web/assets/fonts/MaterialIcons-Regular.otf" ]; then
  cp "build/web/assets/fonts/MaterialIcons-Regular.otf" "build/web/MaterialIcons-Regular.otf"
fi

if [ -f "build/web/assets/assets/branding/pickuplogo.png" ]; then
  cp "build/web/assets/assets/branding/pickuplogo.png" "build/web/pickuplogo.png"
elif [ -f "build/web/assets/assets/branding/pickuplogo.jpg" ]; then
  cp "build/web/assets/assets/branding/pickuplogo.jpg" "build/web/pickuplogo.jpg"
fi
