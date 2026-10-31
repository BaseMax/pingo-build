#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/landing/downloads"
build="$root/ios/build"
mkdir -p "$out"

"$root/scripts/fetch-font.sh"

rm -f "$out/Pingo-source.zip"
(cd "$root" && zip -qr "$out/Pingo-source.zip" ios -x "ios/*.xcodeproj/*" "ios/build/*" "ios/Config/*" "*.DS_Store")

(cd "$root/ios" && xcodegen generate --spec project.yml)
"$root/scripts/build-app.sh" "$build" "$build/logs"
"$root/scripts/make-ipa.sh" "$build/Build/Products/Release-iphoneos" "$out/Pingo.ipa"
"$root/scripts/verify-ipa.sh" "$out/Pingo.ipa"
echo "$out"
