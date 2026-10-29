#!/usr/bin/env bash
# Builds WarmShift with Xcode's toolchain and wraps it in build/WarmShift.app.
# Usage: scripts/bundle.sh [debug|release]
set -euo pipefail
cd "$(dirname "$0")/.."

CONFIG="${1:-release}"
APP="build/WarmShift.app"

xcrun swift build -c "$CONFIG" --product WarmShift
BIN="$(xcrun swift build -c "$CONFIG" --show-bin-path)/WarmShift"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/WarmShift"
cp Resources/Info.plist "$APP/Contents/Info.plist"

# Launch at login (SMAppService) needs a signed bundle. Use an Apple developer identity
# when there is one so macOS keeps the login item across rebuilds; else ad-hoc ("-").
IDENTITY="${SIGN_IDENTITY:-$(security find-identity -v -p codesigning 2>/dev/null \
  | awk -F'"' '/Apple Development|Developer ID Application/ {print $2; exit}')}"
IDENTITY="${IDENTITY:--}"
codesign --force --sign "$IDENTITY" --options runtime "$APP"
echo "Built $APP (signed: $IDENTITY)"
