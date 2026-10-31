#!/usr/bin/env bash
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="${1:-$root/out/smoke}"
shots="${SMOKE_DIR:-/tmp/pingo-smoke}"

mkdir -p "$out" "$shots"
out="$(cd "$out" && pwd)"

if ! xcrun -sdk iphonesimulator metal --version >/dev/null 2>&1; then
  xcodebuild -downloadComponent MetalToolchain
fi

udid="$(python3 -I "$root/scripts/pick-simulator.py")" || exit 1
echo "$udid" > "$out/simulator-udid.txt"
xcrun simctl boot "$udid" || true
xcrun simctl bootstatus "$udid" -b
if [ "${SMOKE_REDUCE_MOTION:-1}" = "1" ]; then
  xcrun simctl spawn "$udid" defaults write com.apple.Accessibility ReduceMotionEnabled -bool true || true
  xcrun simctl shutdown "$udid"
  xcrun simctl boot "$udid"
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl spawn "$udid" defaults read com.apple.Accessibility ReduceMotionEnabled || true
fi
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 || true

cd "$root/ios" && xcodebuild test \
  -project Pingo.xcodeproj -scheme Pingo -configuration Release \
  -destination "id=$udid" -derivedDataPath "$out/derived" \
  -resultBundlePath "$out/Smoke.xcresult" \
  -parallel-testing-enabled NO \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 540 -maximum-test-execution-time-allowance 600 \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO 2>&1 | tee "$out/test.log" | grep -E "error:|Test Case|Test Suite|\*\* TEST|Executed" | cut -c1-200
exit "${PIPESTATUS[0]}"
