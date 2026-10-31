#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: verify-ipa.sh <ipa>" >&2; exit 2; }

root="$(cd "$(dirname "$0")/.." && pwd)"
. "$root/scripts/ipa-common.sh"

ipa="$(absolute "$1")"
work="$(dirname "$ipa")/ipa-verify"
app="$work/Payload/$app_dir"
widget="$app/$widget_rel"
junk='\.dSYM|\.swiftmodule|\.swiftdoc|\.swiftinterface|__MACOSX|\.DS_Store'

fail() {
  echo "verify-ipa: $1" >&2
  exit 1
}

check_listing() {
  local listing
  listing="$(unzip -Z1 "$ipa")"
  echo "$listing" | grep -q "^Payload/$app_dir/Info.plist$" || fail "app bundle missing from Payload"
  echo "$listing" | grep -q "^Payload/$app_dir/$widget_rel/Info.plist$" || fail "widget extension missing from PlugIns"
  ! echo "$listing" | grep -Eq "$junk" || fail "junk files in the ipa: $(echo "$listing" | grep -E "$junk" | head -3)"
}

check_entitlements() {
  local ents group
  group="$(plist_value "$app/Info.plist" PingoGroup)"
  ents="$(codesign -d --entitlements :- "$1" 2>/dev/null || true)"
  echo "$ents" | grep -q 'com.apple.security.application-groups' || fail "$1 has no application-groups entitlement"
  echo "$ents" | grep -q "$group" || fail "$1 entitlement does not list $group"
  ! echo "$ents" | grep -q 'get-task-allow' || fail "$1 carries get-task-allow"
  [ "$(plist_value "$1/Info.plist" PingoGroup)" = "$group" ] || fail "$1 PingoGroup differs from the app"
  echo "verify-ipa: $(basename "$1") entitlements ok ($group)"
}

check_identifiers() {
  local app_id widget_id
  app_id="$(plist_value "$app/Info.plist" CFBundleIdentifier)"
  widget_id="$(plist_value "$widget/Info.plist" CFBundleIdentifier)"
  case "$widget_id" in "$app_id".*) ;; *) fail "widget id $widget_id is not prefixed by $app_id" ;; esac
}

check_signatures() {
  codesign --verify --deep "$app" || fail "signature of $app does not verify"
}

check_listing
clear_dir "$work"
mkdir -p "$work"
unzip -q "$ipa" -d "$work"
check_entitlements "$widget"
check_entitlements "$app"
check_identifiers
check_signatures
clear_dir "$work"
rmdir "$work"
echo "verify-ipa: $ipa ok"
