#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: font-secrets.sh <owner/repo>" >&2; exit 2; }

repo="$1"
root="$(cd "$(dirname "$0")/.." && pwd)"
font="$root/ios/Shared/Fonts/DastoYekan.ttf"
limit=48000

[ -f "$font" ] || { echo "font-secrets: $font is missing" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "font-secrets: gh CLI is not installed" >&2; exit 1; }

encoded="$(base64 < "$font" | tr -d '\n')"
half=$(( (${#encoded} + 1) / 2 ))
first="${encoded:0:half}"
second="${encoded:half}"

for part in "$first" "$second"; do
  [ "${#part}" -lt "$limit" ] || { echo "font-secrets: a half is ${#part} chars, over $limit" >&2; exit 1; }
done

printf '%s' "$first" | gh secret set FONT_B64_1 --repo "$repo"
printf '%s' "$second" | gh secret set FONT_B64_2 --repo "$repo"
echo "font-secrets: FONT_B64_1 (${#first}) and FONT_B64_2 (${#second}) set on $repo"
