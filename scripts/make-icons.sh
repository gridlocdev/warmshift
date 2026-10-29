#!/usr/bin/env bash
# Renders assets/icon.svg (1024 canvas, Apple grid: 824 tile at 100,100) into
# Resources/icon.icns for the .app bundle. Needs Inkscape and macOS iconutil.
# Usage: scripts/make-icons.sh   (or: just icons)
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="assets/icon.svg"
OUT="Resources/icon.icns"
ICONSET="build/icons/icon.iconset"

command -v inkscape >/dev/null || { echo "Inkscape not found (brew install --cask inkscape)" >&2; exit 1; }

rm -rf "$ICONSET"
mkdir -p "$ICONSET"
render() { inkscape "$SRC" --export-type=png --export-filename="$1" -w "$2" -h "$2" 2>/dev/null; }
for size in 16 32 128 256 512; do
  render "$ICONSET/icon_${size}x${size}.png" "$size"
  render "$ICONSET/icon_${size}x${size}@2x.png" $((size * 2))
done
iconutil -c icns "$ICONSET" -o "$OUT"
echo "Wrote $OUT"
