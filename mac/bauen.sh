#!/usr/bin/env bash
# Baut Belegt.app (docs/mac-app.md) und legt sie nach ~/Applications; mit --nur-bauen bleibt sie in mac/.bau.
set -euo pipefail

hier="$(cd "$(dirname "$0")" && pwd)"
projekt="$(dirname "$hier")"
bau="$hier/.bau"
ziel="${BELEGT_APP_ZIEL:-$HOME/Applications}"
app="$bau/Belegt.app"

rm -rf "$bau"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

# Quelltext, Architektur der eigenen Maschine
swiftc -O -swift-version 5 -parse-as-library \
  -target "$(uname -m)-apple-macosx14.0" \
  "$hier"/Quelle/*.swift -o "$app/Contents/MacOS/Belegt"

# Der Ordner mit der compose.yml steht beim Bauen fest und lässt sich in den Einstellungen ändern
sed "s|@STANDARD_ORDNER@|$projekt|" "$hier/Info.plist" > "$app/Contents/Info.plist"
printf 'APPL????' > "$app/Contents/PkgInfo"

# Symbol aus dem Logo der Doku
swiftc -O "$hier/symbol.swift" -o "$bau/symbol"
"$bau/symbol" "$projekt/docs/assets/icon.svg" "$bau/AppIcon.iconset"
iconutil -c icns "$bau/AppIcon.iconset" -o "$app/Contents/Resources/AppIcon.icns"

plutil -lint "$app/Contents/Info.plist" >/dev/null
codesign --force --sign - "$app" >/dev/null

if [[ "${1:-}" == "--nur-bauen" ]]; then
  echo "Gebaut: $app"
  exit 0
fi

mkdir -p "$ziel"
rm -rf "$ziel/Belegt.app"
cp -R "$app" "$ziel/Belegt.app"
echo "Installiert: $ziel/Belegt.app"
