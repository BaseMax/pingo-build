#!/usr/bin/env bash
set -uo pipefail

out="${1:?output directory}"
shots="${SMOKE_DIR:-/tmp/pingo-smoke}"

mkdir -p "$out/attachments" "$out/crash-reports" "$out/shots"
if [ -d "$out/Smoke.xcresult" ]; then
  xcrun xcresulttool export attachments --path "$out/Smoke.xcresult" --output-path "$out/attachments" > "$out/export.log" 2>&1 || true
fi
cp "$HOME"/Library/Logs/DiagnosticReports/*Pingo* "$out/crash-reports/" 2>/dev/null || true
cp "$HOME"/Library/Logs/DiagnosticReports/Retired/*Pingo* "$out/crash-reports/" 2>/dev/null || true
cp -R "$shots/." "$out/shots/" 2>/dev/null || true
echo "smoke-collect: $(ls "$out/shots" | wc -l | tr -d ' ') files in shots"
