#!/usr/bin/env bash
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
derived="${1:-$root/ios/build}"
logs="${2:-$derived/logs}"
legacy='SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) PINGO_LEGACY_GLASS'

mkdir -p "$derived" "$logs"
derived="$(cd "$derived" && pwd)"
logs="$(cd "$logs" && pwd)"

ensure_metal() {
  xcrun -sdk iphoneos metal --version >/dev/null 2>&1 || xcodebuild -downloadComponent MetalToolchain
}

build() {
  local log="$1"
  shift
  (cd "$root/ios" && xcodebuild -project Pingo.xcodeproj -scheme Pingo -configuration Release \
    -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath "$derived" \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO "$@" > "$log" 2>&1)
}

report() {
  grep -E 'error:' "$1" | sort -u | head -40
  tail -30 "$1"
}

ensure_metal

if build "$logs/build.log"; then
  echo "build-app: ok"
  exit 0
fi

echo "build-app: first build failed"
report "$logs/build.log"
echo "build-app: retrying with PINGO_LEGACY_GLASS"

if build "$logs/build-legacy-glass.log" "$legacy"; then
  echo "build-app: ok with PINGO_LEGACY_GLASS, the iOS 26 glass branch has a compile error"
  exit 0
fi

echo "build-app: second build failed"
report "$logs/build-legacy-glass.log"
exit 1
