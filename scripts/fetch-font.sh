#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
font="$root/ios/Shared/Fonts/DastoYekan.ttf"
expected_size=68280
expected_name="IRANYekanXNoEn-DemiBold"

fail() {
  echo "fetch-font: $1" >&2
  exit 1
}

decode() {
  base64 --decode 2>/dev/null || base64 -D
}

file_size() {
  wc -c < "$1" | tr -d ' '
}

verify() {
  local size name
  size="$(file_size "$1")"
  [ "$size" = "$expected_size" ] || fail "wrong size $size, expected $expected_size"
  if command -v python3 >/dev/null 2>&1; then
    name="$(python3 -I "$root/scripts/font-psname.py" "$1" || true)"
    [ "$name" = "$expected_name" ] || fail "wrong PostScript name '$name', expected $expected_name"
  else
    echo "fetch-font: python3 missing, PostScript name not checked" >&2
  fi
}

if [ -f "$font" ]; then
  echo "fetch-font: $font already present, nothing to do"
  exit 0
fi

[ -n "${FONT_B64_1:-}" ] && [ -n "${FONT_B64_2:-}" ] ||
  fail "$font is missing and FONT_B64_1 or FONT_B64_2 is empty. Add both secrets with scripts/font-secrets.sh <owner/repo> and expose them to this step as env."

mkdir -p "$(dirname "$font")"
partial="$font.partial"
trap 'rm -f "$partial"' EXIT

printf '%s%s' "$FONT_B64_1" "$FONT_B64_2" | tr -d ' \r\n' | decode > "$partial" ||
  fail "FONT_B64_1 and FONT_B64_2 are not valid base64"

verify "$partial"
mv "$partial" "$font"
echo "fetch-font: restored $font"
